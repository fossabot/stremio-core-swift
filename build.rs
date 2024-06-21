use glob::glob;
use prost_build::Config;
use std::fs;

fn main() {
    let proto_dir = "src/main/proto";
    let proto_paths = glob(format!("{proto_dir}/**/*.proto").as_str())
        .unwrap()
        .filter_map(Result::ok)
        .collect::<Vec<_>>();
    for path in &proto_paths {
        let display_path = path.display();
        println!("cargo:rerun-if-changed={display_path}");
    }
    let file_descriptors =
        protox::compile(proto_paths, [proto_dir]).expect("Expected file descriptors");

    let out_dir = "src/commonMain/rust/protobuf";

    fs::create_dir_all(out_dir).expect("Failed to create output directory");

    Config::new()
        .compile_well_known_types()
        .out_dir(out_dir)
        .include_file("mod.rs")
        .compile_fds(file_descriptors)
        .expect("Expected successful protobuf codegen");
}
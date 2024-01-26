use crate::bridge::{FromProtobuf, ToProtobuf};
use crate::model::AppleModelField;
use crate::protobuf::stremio::core::runtime::Field;

impl FromProtobuf<AppleModelField> for Field {
    fn from_protobuf(&self) -> AppleModelField {
        match self {
            Field::Ctx => AppleModelField::Ctx,
            Field::AuthLink => AppleModelField::AuthLink,
            Field::ContinueWatchingPreview => AppleModelField::ContinueWatchingPreview,
            Field::Discover => AppleModelField::Discover,
            Field::Library => AppleModelField::Library,
            Field::LibraryByType => AppleModelField::LibraryByType,
            Field::Board => AppleModelField::Board,
            Field::Search => AppleModelField::Search,
            Field::MetaDetails => AppleModelField::MetaDetails,
            Field::Addons => AppleModelField::Addons,
            Field::AddonDetails => AppleModelField::AddonDetails,
            Field::StreamingServer => AppleModelField::StreamingServer,
            Field::Player => AppleModelField::Player,
        }
    }
}

impl ToProtobuf<Field, ()> for AppleModelField {
    fn to_protobuf(&self, _args: &()) -> Field {
        match self {
            AppleModelField::Ctx => Field::Ctx,
            AppleModelField::AuthLink => Field::AuthLink,
            AppleModelField::ContinueWatchingPreview => Field::ContinueWatchingPreview,
            AppleModelField::Discover => Field::Discover,
            AppleModelField::Library => Field::Library,
            AppleModelField::LibraryByType => Field::LibraryByType,
            AppleModelField::Board => Field::Board,
            AppleModelField::Search => Field::Search,
            AppleModelField::MetaDetails => Field::MetaDetails,
            AppleModelField::Addons => Field::Addons,
            AppleModelField::AddonDetails => Field::AddonDetails,
            AppleModelField::StreamingServer => Field::StreamingServer,
            AppleModelField::Player => Field::Player,
        }
    }
}

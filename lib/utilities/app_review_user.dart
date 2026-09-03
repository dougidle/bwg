/// Reserved account used for App Store / Play Store review and TestFlight testing.
///
/// This user must always be treated as a subscriber (so review builds can book
/// any Thursday without hitting the non-subscriber restrictions), must never have
/// that subscriber status reset by the app, and must never be visible to any other
/// user - it should only appear on screen when someone is actually logged in as it.
const int appReviewUserId = 42;

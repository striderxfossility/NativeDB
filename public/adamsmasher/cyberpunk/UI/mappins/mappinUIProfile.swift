
public native struct MappinUIProfile {

  private native let widgetResource: ResRef;

  private native let widgetLibraryID: CName;

  private native let spawn: ref<MappinUISpawnProfile_Record>;

  private native let runtime: ref<MappinUIRuntimeProfile_Record>;

  public final static func CreateDefault(_widgetResource: ResRef) -> MappinUIProfile {
    return MappinUIProfile.Create(_widgetResource, t"MappinUISpawnProfile.MediumRange");
  }

  public final static func Create(_widgetResource: ResRef, spawnProfile: TweakDBID) -> MappinUIProfile {
    return MappinUIProfile.Create(_widgetResource, spawnProfile, t"MappinUIRuntimeProfile.Default");
  }

  public final static func Create(_widgetResource: ResRef, spawnProfile: TweakDBID, runtimeProfile: TweakDBID) -> MappinUIProfile {
    let profile: MappinUIProfile;
    profile.widgetResource = _widgetResource;
    profile.spawn = TweakDBInterface.GetMappinUISpawnProfileRecord(spawnProfile);
    profile.runtime = TweakDBInterface.GetMappinUIRuntimeProfileRecord(runtimeProfile);
    return profile;
  }

  public final static func None() -> MappinUIProfile {
    let profile: MappinUIProfile;
    return profile;
  }
}


public class CharacterLevelUpGameController extends inkHUDGameController {

  private edit let m_value: inkTextRef;

  private edit let m_proficencyLabel: inkTextRef;

  private let m_stateChangesBlackboardId: Uint32;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_data: ref<LevelUpUserData>;

  protected cb func OnInitialize() -> Bool {
    this.m_data = this.GetRootWidget().GetUserData(n"LevelUpUserData") as LevelUpUserData;
    this.Setup();
  }

  protected cb func OnUninitialize() -> Bool;

  private final func Setup() -> Void {
    let levelInfo: LevelUpData = this.m_data.data;
    let profString: String = EnumValueToString("gamedataProficiencyType", Cast(EnumInt(levelInfo.type)));
    let proficiencyRecord: ref<Proficiency_Record> = TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + profString));
    if Equals(levelInfo.type, gamedataProficiencyType.Level) || Equals(levelInfo.type, gamedataProficiencyType.StreetCred) {
      if Equals(levelInfo.type, gamedataProficiencyType.Level) {
        inkTextRef.SetText(this.m_proficencyLabel, "UI-Cyberpunk-Widgets-Notifications-CharacterLevelUp-LevelUp");
      } else {
        inkTextRef.SetLetterCase(this.m_proficencyLabel, textLetterCase.UpperCase);
        inkTextRef.SetText(this.m_proficencyLabel, proficiencyRecord.Loc_name_key());
      };
      inkTextRef.SetText(this.m_value, IntToString(levelInfo.lvl));
      this.PlayIntroAnimation();
    };
  }

  private final func PlayIntroAnimation() -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(n"level_up");
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    let fakeData: ref<inkGameNotificationData>;
    this.m_data.token.TriggerCallback(fakeData);
  }
}

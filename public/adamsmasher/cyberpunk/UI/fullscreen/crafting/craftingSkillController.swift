
public class CraftingSkillWidget extends inkGameController {

  protected edit let m_amountText: inkTextRef;

  protected edit let m_expFill: inkWidgetRef;

  protected edit let m_perkHolder: inkWidgetRef;

  protected edit let m_levelUpAnimation: inkWidgetRef;

  protected edit let m_expAnimation: inkWidgetRef;

  protected edit let m_nextLevelText: inkTextRef;

  protected edit let m_expPointText1: inkTextRef;

  protected edit let m_expPointText2: inkTextRef;

  private let m_levelUpBlackboard: wref<IBlackboard>;

  private let m_playerLevelUpListener: ref<CallbackHandle>;

  private let m_isLevelUp: Bool;

  private let m_currentExp: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_levelUpBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_LevelUp);
    this.m_playerLevelUpListener = this.m_levelUpBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this, n"OnCharacterLevelUpdated");
    this.SetProgress();
    this.SetLevel();
  }

  protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
    if Equals(evt.type, gamedataProficiencyType.Crafting) && !this.m_isLevelUp {
      this.SetProgress();
      inkWidgetRef.SetVisible(this.m_expAnimation, true);
      this.PlayLibraryAnimation(n"exp_points_gain");
    };
    this.m_isLevelUp = false;
  }

  protected cb func OnCharacterLevelUpdated(value: Variant) -> Bool {
    let levelUpData: LevelUpData = FromVariant(value);
    if Equals(levelUpData.type, gamedataProficiencyType.Crafting) {
      this.m_isLevelUp = true;
      this.SetLevel();
      inkWidgetRef.SetVisible(this.m_levelUpAnimation, true);
      this.PlayLibraryAnimation(n"SKILLBAR_lvlup");
      this.SetProgress();
    };
  }

  private final func SetLevel() -> Void {
    let puppet: wref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
    let playerDevelopmentSystem: wref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer((this.GetOwnerEntity() as GameObject).GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    inkTextRef.SetText(this.m_nextLevelText, IntToString(playerDevelopmentSystem.GetProficiencyLevel(puppet, gamedataProficiencyType.Crafting)));
    inkTextRef.SetText(this.m_amountText, IntToString(playerDevelopmentSystem.GetProficiencyLevel(puppet, gamedataProficiencyType.Crafting)));
  }

  private final func SetProgress() -> Void {
    let currentFill: Float;
    let totalExp: Int32;
    let puppet: wref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
    let playerDevelopmentSystem: wref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer((this.GetOwnerEntity() as GameObject).GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    let currExp: Int32 = playerDevelopmentSystem.GetCurrentLevelProficiencyExp(puppet, gamedataProficiencyType.Crafting);
    let addExp: Int32 = currExp - this.m_currentExp;
    this.m_currentExp = currExp;
    let remainingExp: Int32 = playerDevelopmentSystem.GetRemainingExpForLevelUp(puppet, gamedataProficiencyType.Crafting);
    let expParams: ref<inkTextParams> = new inkTextParams();
    expParams.AddNumber("VALUE", addExp);
    (inkWidgetRef.Get(this.m_expPointText1) as inkText).SetLocalizedTextScript("LocKey#42794", expParams);
    (inkWidgetRef.Get(this.m_expPointText2) as inkText).SetLocalizedTextScript("LocKey#42794", expParams);
    this.m_currentExp = currExp;
    totalExp = currExp + remainingExp;
    currentFill = Cast(currExp) / Cast(totalExp);
    if playerDevelopmentSystem.IsProficiencyMaxLvl(puppet, gamedataProficiencyType.Crafting) {
      currentFill = 1.00;
    };
    this.SetFill(currentFill);
  }

  private final func SetFill(amount: Float) -> Void {
    inkWidgetRef.SetScale(this.m_expFill, new Vector2(amount, 1.00));
  }

  private final func AddPerk(toAdd: gamedataPerkType) -> Void {
    let imageWidget: wref<inkImage> = (this.SpawnFromLocal(inkWidgetRef.Get(this.m_perkHolder), n"perkImage") as inkCompoundWidget).GetWidgetByIndex(0) as inkImage;
    InkImageUtils.RequestSetImage(this, imageWidget, "UIIcon." + ToString(toAdd));
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_levelUpBlackboard) {
      this.m_levelUpBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this.m_playerLevelUpListener);
    };
  }
}

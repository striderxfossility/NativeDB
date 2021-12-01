
public native class ConfigVarBool extends ConfigVar {

  public final native func SetValue(value: Bool) -> Void;

  public final native func GetValue() -> Bool;

  public final native func GetDefaultValue() -> Bool;

  public final func Toggle() -> Void {
    this.SetValue(!this.GetValue());
  }
}

public class GameplaySettingsSystem extends ScriptableSystem {

  private persistent let m_gameplaySettingsListener: ref<GameplaySettingsListener>;

  private persistent let m_wasEverJohnny: Bool;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = request.owner as PlayerPuppet;
    if IsDefined(player) {
      this.m_gameplaySettingsListener = new GameplaySettingsListener();
      this.m_gameplaySettingsListener.Initialize(player);
    };
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      this.m_gameplaySettingsListener = new GameplaySettingsListener();
      this.m_gameplaySettingsListener.Initialize(player);
    };
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void;

  public final static func GetGameplaySettingsSystemInstance(owner: ref<GameObject>) -> ref<GameplaySettingsSystem> {
    return GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"GameplaySettingsSystem") as GameplaySettingsSystem;
  }

  public final static func GetAdditiveCameraMovementsSetting(owner: ref<GameObject>) -> Float {
    return GameplaySettingsSystem.GetGameplaySettingsSystemInstance(owner).m_gameplaySettingsListener.m_additiveCameraMovements;
  }

  public final static func GetIsFastForwardByLine(owner: ref<GameObject>) -> Bool {
    return GameplaySettingsSystem.GetGameplaySettingsSystemInstance(owner).m_gameplaySettingsListener.m_isFastForwardByLine;
  }

  public final static func GetMovementDodgeEnabled(owner: ref<GameObject>) -> Bool {
    return GameplaySettingsSystem.GetGameplaySettingsSystemInstance(owner).m_gameplaySettingsListener.m_movementDodgeEnabled;
  }

  public final static func WasEverJohnny(owner: ref<GameObject>) -> Bool {
    return GameplaySettingsSystem.GetGameplaySettingsSystemInstance(owner).m_wasEverJohnny;
  }

  public final static func SetWasEverJohnny(owner: ref<GameObject>, value: Bool) -> Void {
    GameplaySettingsSystem.GetGameplaySettingsSystemInstance(owner).SetWasEverJohnny(value);
  }

  public final const func GetIsFastForwardByLine() -> Bool {
    return this.m_gameplaySettingsListener.m_isFastForwardByLine;
  }

  public final const func GetIsInputHintEnabled() -> Bool {
    return this.m_gameplaySettingsListener.m_InputHintsEnabled;
  }

  private final func SetWasEverJohnny(value: Bool) -> Void {
    this.m_wasEverJohnny = value;
  }
}

public class GameplaySettingsListener extends ConfigVarListener {

  private let m_player: wref<PlayerPuppet>;

  private let m_userSettings: ref<UserSettings>;

  private let m_diffSettingsGroup: ref<ConfigGroup>;

  private let m_miscSettingsGroup: ref<ConfigGroup>;

  private let m_controlsGroup: ref<ConfigGroup>;

  private let m_hudGroup: ref<ConfigGroup>;

  public let m_additiveCameraMovements: Float;

  public let m_isFastForwardByLine: Bool;

  public let m_movementDodgeEnabled: Bool;

  public let m_InputHintsEnabled: Bool;

  @default(GameplaySettingsListener, AdditiveCameraMovements)
  private let m_additiveCameraGroupName: CName;

  @default(GameplaySettingsListener, FastForward)
  private let m_fastForwardGroupName: CName;

  @default(GameplaySettingsListener, MovementDodge)
  private let m_movementDodgeGroupName: CName;

  @default(GameplaySettingsListener, /gameplay/difficulty)
  private let m_difficultyPath: CName;

  @default(GameplaySettingsListener, /gameplay/misc)
  private let m_miscPath: CName;

  @default(GameplaySettingsListener, /controls)
  private let m_controlsPath: CName;

  @default(GameplaySettingsListener, /interface/hud)
  private let m_hudPath: CName;

  @default(GameplaySettingsListener, input_hints)
  private let m_hintsName: CName;

  public final func Initialize(player: wref<PlayerPuppet>) -> Void {
    this.m_player = player;
    this.m_userSettings = GameInstance.GetSettingsSystem(this.m_player.GetGame());
    this.m_diffSettingsGroup = this.m_userSettings.GetGroup(this.m_difficultyPath);
    this.m_miscSettingsGroup = this.m_userSettings.GetGroup(this.m_miscPath);
    this.m_controlsGroup = this.m_userSettings.GetGroup(this.m_controlsPath);
    this.m_hudGroup = this.m_userSettings.GetGroup(this.m_hudPath);
    this.Register(this.m_difficultyPath);
    this.Register(this.m_miscPath);
    this.Register(this.m_controlsPath);
    this.Register(this.m_hudPath);
    this.UpdateInputHintsEnabled();
    this.RefreshAdditiveCameraMovementsSetting();
    this.UpdateFFSetting();
    this.UpdateMovementDodgeSettings();
    if IsDefined(this.m_player) {
      this.m_player.OnAdditiveCameraMovementsSettingChanged();
      this.RestoreJohnnyRelatedState();
    };
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    if NotEquals(reason, ConfigChangeReason.Accepted) {
      return;
    };
    switch varName {
      case this.m_hintsName:
        this.UpdateInputHintsEnabled();
        break;
      case this.m_additiveCameraGroupName:
        this.RefreshAdditiveCameraMovementsSetting();
        this.m_player.OnAdditiveCameraMovementsSettingChanged();
        break;
      case this.m_fastForwardGroupName:
        this.UpdateFFSetting();
        break;
      case this.m_movementDodgeGroupName:
        this.UpdateMovementDodgeSettings();
        break;
      default:
    };
  }

  private final func UpdateInputHintsEnabled() -> Void {
    let settingsVar: ref<ConfigVarBool>;
    if IsDefined(this.m_hudGroup) {
      settingsVar = this.m_hudGroup.GetVar(this.m_hintsName) as ConfigVarBool;
      if IsDefined(settingsVar) {
        this.m_InputHintsEnabled = settingsVar.GetValue();
      };
    };
  }

  private final func RefreshAdditiveCameraMovementsSetting() -> Void {
    let additiveCameraMovementsVar: ref<ConfigVarListFloat>;
    if IsDefined(this.m_diffSettingsGroup) {
      additiveCameraMovementsVar = this.m_diffSettingsGroup.GetVar(this.m_additiveCameraGroupName) as ConfigVarListFloat;
      if IsDefined(additiveCameraMovementsVar) {
        this.m_additiveCameraMovements = additiveCameraMovementsVar.GetValue();
      };
    };
  }

  private final func RestoreJohnnyRelatedState() -> Void {
    let johnnyHUDVar: ref<ConfigVar>;
    if GameplaySettingsSystem.WasEverJohnny(this.m_player) {
      johnnyHUDVar = this.m_userSettings.GetVar(n"/interface/hud", n"johnny_hud");
      johnnyHUDVar.SetVisible(true);
    };
  }

  private final func UpdateFFSetting() -> Void {
    let FFSettingsVar: ref<ConfigVarListString>;
    if IsDefined(this.m_miscSettingsGroup) {
      FFSettingsVar = this.m_miscSettingsGroup.GetVar(this.m_fastForwardGroupName) as ConfigVarListString;
      this.m_isFastForwardByLine = FFSettingsVar.GetIndex() == 0;
    };
  }

  private final func UpdateMovementDodgeSettings() -> Void {
    let controlsSettingsVar: ref<ConfigVarBool>;
    if IsDefined(this.m_controlsGroup) && this.m_controlsGroup.HasVar(this.m_movementDodgeGroupName) {
      controlsSettingsVar = this.m_controlsGroup.GetVar(this.m_movementDodgeGroupName) as ConfigVarBool;
      this.m_movementDodgeEnabled = controlsSettingsVar.GetValue();
    } else {
      this.m_movementDodgeEnabled = true;
    };
  }
}

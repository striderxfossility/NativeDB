
public class CompanionHealthStatListener extends ScriptStatPoolsListener {

  private let m_healthbar: wref<CompanionHealthBarGameController>;

  public final func BindHealthbar(bar: ref<CompanionHealthBarGameController>) -> Void {
    this.m_healthbar = bar;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_healthbar.UpdateHealthValue(newValue);
  }
}

public class CompanionHealthBarGameController extends inkHUDGameController {

  private edit let m_healthbar: inkWidgetRef;

  private let m_root: wref<inkWidget>;

  private let m_flatheadListener: ref<CallbackHandle>;

  private let m_isActive: Bool;

  private let m_maxHealth: Float;

  private let m_healthStatListener: ref<CompanionHealthStatListener>;

  private let m_companionBlackboard: wref<IBlackboard>;

  private let m_gameInstance: GameInstance;

  private let m_statPoolsSystem: ref<StatPoolsSystem>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
    this.m_companionBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Companion);
    this.m_flatheadListener = this.m_companionBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_Companion.flatHeadSpawned, this, n"OnFlatheadStatusChanged");
    this.m_gameInstance = (this.GetOwnerEntity() as PlayerPuppet).GetGame();
    this.m_statPoolsSystem = GameInstance.GetStatPoolsSystem(this.m_gameInstance);
    this.m_healthStatListener = new CompanionHealthStatListener();
    this.m_healthStatListener.BindHealthbar(this);
  }

  protected cb func OnFlatheadStatusChanged(value: Bool) -> Bool {
    if NotEquals(this.m_isActive, value) {
      this.m_isActive = value;
      if this.m_isActive {
        this.RegisterStatsListener();
        this.m_root.SetVisible(true);
      } else {
        this.m_root.SetVisible(false);
        this.UnregisterStatsListener();
      };
    };
  }

  private final func RegisterStatsListener() -> Void {
    let flatheadPuppet: wref<ScriptedPuppet> = SubCharacterSystem.GetInstance(this.m_gameInstance).GetFlathead();
    let flatheadEntityID: EntityID = flatheadPuppet.GetEntityID();
    this.m_statPoolsSystem.RequestRegisteringListener(Cast(flatheadEntityID), gamedataStatPoolType.Health, this.m_healthStatListener);
    this.m_maxHealth = this.m_statPoolsSystem.GetStatPoolMaxPointValue(Cast(flatheadEntityID), gamedataStatPoolType.Health);
  }

  private final func UnregisterStatsListener() -> Void {
    let flatheadPuppet: wref<ScriptedPuppet> = SubCharacterSystem.GetInstance(this.m_gameInstance).GetFlathead();
    let flatheadEntityID: EntityID = flatheadPuppet.GetEntityID();
    this.m_statPoolsSystem.RequestUnregisteringListener(Cast(flatheadEntityID), gamedataStatPoolType.Health, this.m_healthStatListener);
  }

  public final func UpdateHealthValue(value: Float) -> Void {
    inkWidgetRef.SetScale(this.m_healthbar, new Vector2(value / this.m_maxHealth, 1.00));
  }
}

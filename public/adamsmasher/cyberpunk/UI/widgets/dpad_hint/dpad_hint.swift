
public class HotkeysWidgetController extends inkHUDGameController {

  private edit let m_hotkeysList: inkHorizontalPanelRef;

  private edit let m_utilsList: inkHorizontalPanelRef;

  private edit let m_phone: wref<inkWidget>;

  private edit let m_car: wref<inkWidget>;

  private edit let m_consumables: wref<inkWidget>;

  private edit let m_gadgets: wref<inkWidget>;

  private let m_player: wref<PlayerPuppet>;

  private let m_root: wref<inkCompoundWidget>;

  private let m_gameInstance: GameInstance;

  private let m_fact1ListenerId: Uint32;

  private let m_fact2ListenerId: Uint32;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    if !IsDefined(this.m_player) {
      return false;
    };
    this.m_phone = this.SpawnFromLocal(inkWidgetRef.Get(this.m_utilsList), n"DPAD_DOWN");
    this.m_car = this.SpawnFromLocal(inkWidgetRef.Get(this.m_utilsList), n"DPAD_RIGHT");
    this.m_consumables = this.SpawnFromLocal(inkWidgetRef.Get(this.m_hotkeysList), n"DPAD_UP");
    this.m_gadgets = this.SpawnFromLocal(inkWidgetRef.Get(this.m_hotkeysList), n"RB");
    this.m_fact1ListenerId = GameInstance.GetQuestsSystem(this.m_player.GetGame()).RegisterListener(n"dpad_hints_visibility_enabled", this, n"OnConsumableTutorial");
    this.m_fact2ListenerId = GameInstance.GetQuestsSystem(this.m_player.GetGame()).RegisterListener(n"q000_started", this, n"OnGameStarted");
    this.ResolveVisibility();
    this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
  }

  protected cb func OnUninitialize() -> Bool {
    GameInstance.GetQuestsSystem(this.m_gameInstance).UnregisterListener(n"dpad_hints_visibility_enabled", this.m_fact1ListenerId);
    GameInstance.GetQuestsSystem(this.m_gameInstance).UnregisterListener(n"q000_started", this.m_fact2ListenerId);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let controlledPuppetRecordID: TweakDBID;
    let controlledPuppet: wref<gamePuppetBase> = GetPlayer(this.m_gameInstance);
    if controlledPuppet != null {
      controlledPuppetRecordID = controlledPuppet.GetRecordID();
      if controlledPuppetRecordID == t"Character.johnny_replacer" {
        inkWidgetRef.SetMargin(this.m_hotkeysList, new inkMargin(84.00, 0.00, 0.00, 0.00));
      } else {
        inkWidgetRef.SetMargin(this.m_hotkeysList, new inkMargin(331.00, 0.00, 0.00, 0.00));
      };
    } else {
      inkWidgetRef.SetMargin(this.m_hotkeysList, new inkMargin(331.00, 0.00, 0.00, 0.00));
    };
  }

  public final func OnConsumableTutorial(val: Int32) -> Void {
    this.ResolveVisibility();
  }

  public final func OnGameStarted(val: Int32) -> Void {
    this.ResolveVisibility();
  }

  private final func ResolveVisibility() -> Void {
    if this.GameStarted() && !this.TutorialActivated() {
      this.GetRootWidget().SetVisible(false);
      return;
    };
    if this.GameStarted() && this.TutorialActivated() {
      this.GetRootWidget().SetVisible(true);
      return;
    };
    if !this.GameStarted() {
      if !this.TutorialActivated() {
        this.GetRootWidget().SetVisible(true);
      };
    };
  }

  private final func GameStarted() -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_player.GetGame());
    if IsDefined(qs) {
      return Cast(qs.GetFact(n"q000_started"));
    };
    return false;
  }

  private final func TutorialActivated() -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_player.GetGame());
    if IsDefined(qs) {
      return Cast(qs.GetFact(n"dpad_hints_visibility_enabled"));
    };
    return false;
  }
}

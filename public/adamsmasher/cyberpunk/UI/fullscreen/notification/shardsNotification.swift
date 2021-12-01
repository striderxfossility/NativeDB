
public class ShardNotificationController extends inkGameController {

  private edit let m_titleRef: inkTextRef;

  private edit let m_shortTextRef: inkTextRef;

  private edit let m_longTextRef: inkTextRef;

  private edit let m_shortTextHolderRef: inkWidgetRef;

  private edit let m_longTextHolderRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerParentRef: inkWidgetRef;

  private edit let m_buttonHintsSecondaryManagerRef: inkWidgetRef;

  private edit let m_buttonHintsSecondaryManagerParentRef: inkWidgetRef;

  private let m_data: ref<ShardReadPopupData>;

  @default(ShardNotificationController, 1000)
  private let m_longTextTrashold: Int32;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_player: wref<PlayerPuppet>;

  private let m_mingameBB: wref<IBlackboard>;

  protected cb func OnInitialize() -> Bool {
    let shardText: String;
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
    this.m_data = this.GetRootWidget().GetUserData(n"ShardReadPopupData") as ShardReadPopupData;
    shardText = CodexUtils.GetShardTextString(this.m_data.isCrypted, this.m_data.text);
    inkTextRef.SetText(this.m_longTextRef, shardText);
    inkTextRef.SetText(this.m_titleRef, CodexUtils.GetShardTitleString(this.m_data.isCrypted, this.m_data.title));
    this.SetButtonHints();
    this.PlayAnim(n"intro", n"OnIntroComplete");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
    this.GetSystemRequestsHandler().UnpauseGame();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_player = playerPuppet as PlayerPuppet;
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"OpenPauseMenu") {
      evt.Handle();
      this.Close();
    };
    if evt.IsAction(n"cancel") {
      this.Close();
    };
    if evt.IsAction(n"one_click_confirm") {
      this.LaunchMinigame();
    };
  }

  protected cb func OnCloseClick(controller: wref<inkButtonController>) -> Bool {
    this.Close();
  }

  protected cb func OnCrackClick(controller: wref<inkButtonController>) -> Bool {
    this.LaunchMinigame();
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.PlaySound(n"ShardPanel", n"OnOpen");
    this.GetSystemRequestsHandler().PauseGame();
  }

  private final func Close() -> Void {
    this.PlaySound(n"ShardPanel", n"OnClose");
    this.GetSystemRequestsHandler().UnpauseGame();
    this.m_data.token.TriggerCallback(this.m_data);
  }

  private final func SetButtonHints() -> Void {
    this.AddButtonHints(n"cancel", n"Common-Access-Close", this.m_buttonHintsManagerParentRef, n"OnCloseClick");
    inkWidgetRef.SetVisible(this.m_buttonHintsSecondaryManagerParentRef, this.m_data.isCrypted);
    if this.m_data.isCrypted {
      this.AddButtonHints(n"one_click_confirm", n"UI-Notifications-Crack", this.m_buttonHintsSecondaryManagerRef, n"OnCrackClick");
    };
  }

  private final func LaunchMinigame() -> Void {
    this.m_mingameBB = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame);
    this.m_mingameBB.SetBool(GetAllBlackboardDefs().HackingMinigame.IsJournalTarget, false);
    ItemActionsHelper.PerformItemAction(this.m_player, this.m_data.itemID);
    this.Close();
  }

  private final func AddButtonHints(actionName: CName, label: CName, buttonHintRef: inkWidgetRef, clickCallback: CName) -> Void {
    let buttonHint: ref<LabelInputDisplayController>;
    let widget: wref<inkWidget>;
    let buttonController: wref<inkButtonController> = inkWidgetRef.GetController(buttonHintRef) as inkButtonController;
    buttonController.RegisterToCallback(n"OnButtonClick", this, clickCallback);
    widget = this.SpawnFromExternal(inkWidgetRef.Get(buttonHintRef), r"base\\gameplay\\gui\\common\\buttons\\base_buttons.inkwidget", n"inputDisplayLabelFlex");
    buttonHint = widget.GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(actionName, GetLocalizedTextByKey(label));
    widget.SetHAlign(inkEHorizontalAlign.Center);
    widget.SetVAlign(inkEVerticalAlign.Center);
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }
}

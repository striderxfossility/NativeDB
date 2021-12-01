
public class BaseModalListPopupTemplateClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    return 0u;
  }
}

public class BaseModalListPopupGameController extends inkGameController {

  protected edit let m_content: inkWidgetRef;

  protected let m_listController: wref<inkVirtualListController>;

  protected let m_playerPuppet: wref<GameObject>;

  protected let m_popupData: ref<inkGameNotificationData>;

  private let m_templateClassifier: ref<BaseModalListPopupTemplateClassifier>;

  private let m_systemRequestsHandler: wref<inkISystemRequestsHandler>;

  private let m_switchAnimProxy: ref<inkAnimProxy>;

  private let m_transitionAnimProxy: ref<inkAnimProxy>;

  private let m_isInMenuCallbackID: ref<CallbackHandle>;

  @default(BaseModalListPopupGameController, 0.75f)
  private const let c_scrollInputThreshold: Float;

  private let m_firstInit: Bool;

  protected func SetupData() -> Void;

  protected func SetupVirtualList() -> Void;

  protected func CleanVirtualList() -> Void;

  protected func Activate() -> Void;

  protected func VirtualListReady() -> Void;

  protected func Select(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Void;

  protected func OnClose() -> Void;

  protected cb func OnInitialize() -> Bool {
    this.m_popupData = this.GetRootWidget().GetUserData(n"inkGameNotificationData") as inkGameNotificationData;
    this.m_systemRequestsHandler = this.GetSystemRequestsHandler();
    this.SetTimeDilatation(true);
    this.BaseSetupVirtualList();
    this.m_transitionAnimProxy = this.PlayLibraryAnimation(n"fadeIn");
    PopupStateUtils.SetBackgroundBlurBlendTime(this, 0.10);
  }

  protected cb func OnUninitialize() -> Bool {
    this.SendPSMRadialCloseRequest();
    this.SetTimeDilatation(false);
    this.CleanVirtualList();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let playerControlledObject: ref<GameObject>;
    let uiSystemBB: ref<IBlackboard>;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(playerPuppet.GetGame());
    uiSystem.PushGameContext(UIGameContext.ModalPopup);
    uiSystem.RequestNewVisualState(n"inkModalPopupState");
    this.m_playerPuppet = playerPuppet;
    playerControlledObject = this.GetPlayerControlledObject();
    this.SetupData();
    playerControlledObject.RegisterInputListener(this, n"left_stick_y_scroll_up");
    playerControlledObject.RegisterInputListener(this, n"left_stick_y_scroll_down");
    playerControlledObject.RegisterInputListener(this, n"popup_moveDown");
    playerControlledObject.RegisterInputListener(this, n"popup_moveUp");
    playerControlledObject.RegisterInputListener(this, n"OpenPauseMenu");
    playerControlledObject.RegisterInputListener(this, n"proceed");
    playerControlledObject.RegisterInputListener(this, n"cancel");
    uiSystemBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    this.m_isInMenuCallbackID = uiSystemBB.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_System.IsInMenu, this, n"OnIsInMenuChanged");
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    let uiSystemBB: ref<IBlackboard>;
    if IsDefined(this.m_isInMenuCallbackID) {
      uiSystemBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
      uiSystemBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_System.IsInMenu, this.m_isInMenuCallbackID);
    };
    this.GetPlayerControlledObject().UnregisterInputListener(this);
  }

  protected cb func OnIsInMenuChanged(param: Bool) -> Bool {
    if param {
      this.Close();
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionType: gameinputActionType = ListenerAction.GetType(action);
    let actionName: CName = ListenerAction.GetName(action);
    if Equals(actionType, gameinputActionType.REPEAT) {
      switch actionName {
        case n"popup_moveUp":
          this.ScrollPrior();
          break;
        case n"popup_moveDown":
          this.ScrollNext();
      };
    } else {
      if Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
        switch actionName {
          case n"proceed":
            this.Activate();
            break;
          case n"popup_moveUp":
            this.ScrollPrior();
            break;
          case n"popup_moveDown":
            this.ScrollNext();
            break;
          case n"OpenPauseMenu":
            ListenerActionConsumer.DontSendReleaseEvent(consumer);
            this.Close();
            break;
          case n"cancel":
            this.Close();
        };
      } else {
        if Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
          if Equals(actionName, n"left_stick_y_scroll_up") {
            this.ScrollPrior();
          } else {
            if Equals(actionName, n"left_stick_y_scroll_down") {
              this.ScrollNext();
            };
          };
        };
      };
    };
  }

  protected cb func OnItemSelected(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
    this.Select(previous, next);
    if IsDefined(this.m_switchAnimProxy) {
      this.m_switchAnimProxy.Stop();
      this.m_switchAnimProxy = null;
    };
    this.m_switchAnimProxy = this.PlayLibraryAnimation(n"switch");
  }

  private final func BaseSetupVirtualList() -> Void {
    this.m_templateClassifier = new BaseModalListPopupTemplateClassifier();
    this.m_listController = inkWidgetRef.GetControllerByType(this.m_content, n"inkVirtualListController") as inkVirtualListController;
    this.m_listController.SetClassifier(this.m_templateClassifier);
    this.m_listController.RegisterToCallback(n"OnItemSelected", this, n"OnItemSelected");
    this.m_listController.RegisterToCallback(n"OnAllElementsSpawned", this, n"OnAllElementsSpawned");
    this.m_firstInit = true;
    this.SetupVirtualList();
  }

  protected cb func OnAllElementsSpawned() -> Bool {
    if this.m_firstInit {
      this.m_firstInit = false;
      this.m_listController.SelectItem(0u);
      this.VirtualListReady();
    };
  }

  private final func HandleScroll(axisData: Float) -> Void {
    if AbsF(axisData) >= this.c_scrollInputThreshold {
      if axisData > 0.00 {
        this.ScrollNext();
      } else {
        this.ScrollPrior();
      };
    };
  }

  private final func ScrollNext() -> Void {
    if IsDefined(this.m_listController) {
      this.m_listController.Navigate(inkDiscreteNavigationDirection.Down);
    };
  }

  private final func ScrollPrior() -> Void {
    if IsDefined(this.m_listController) {
      this.m_listController.Navigate(inkDiscreteNavigationDirection.Up);
    };
  }

  protected final func Close() -> Void {
    if IsDefined(this.m_transitionAnimProxy) {
      this.m_transitionAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHideAnimFinished");
      this.m_transitionAnimProxy.Stop();
      this.m_transitionAnimProxy = null;
    };
    this.m_transitionAnimProxy = this.PlayLibraryAnimation(n"fadeOut");
    this.m_transitionAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHideAnimFinished");
    this.OnClose();
  }

  private final func SendPSMRadialCloseRequest() -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"RadialWheelCloseRequest";
    psmEvent.value = true;
    this.m_playerPuppet.QueueEvent(psmEvent);
  }

  protected cb func OnHideAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.SetTimeDilatation(false);
    this.m_popupData.token.TriggerCallback(this.m_popupData);
  }

  protected final func SetTimeDilatation(enable: Bool) -> Void {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.m_playerPuppet.GetGame());
    if enable {
      TimeDilationHelper.SetTimeDilationWithProfile(this.GetPlayerControlledObject(), "radialMenu", true);
      uiSystem.PushGameContext(UIGameContext.ModalPopup);
      uiSystem.RequestNewVisualState(n"inkModalPopupState");
      PopupStateUtils.SetBackgroundBlur(this, true);
    } else {
      TimeDilationHelper.SetTimeDilationWithProfile(this.GetPlayerControlledObject(), "radialMenu", false);
      uiSystem.PopGameContext(UIGameContext.ModalPopup);
      uiSystem.RestorePreviousVisualState(n"inkModalPopupState");
      PopupStateUtils.SetBackgroundBlur(this, false);
    };
  }
}

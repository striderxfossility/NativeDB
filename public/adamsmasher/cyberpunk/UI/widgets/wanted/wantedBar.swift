
public class WantedBarGameController extends inkHUDGameController {

  private edit const let starsWidget: array<inkWidgetRef>;

  private let m_wantedBlackboard: wref<IBlackboard>;

  private let m_wantedBlackboardDef: ref<UI_WantedBarDef>;

  private let m_wantedCallbackID: ref<CallbackHandle>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_attentionAnimProxy: ref<inkAnimProxy>;

  private let m_bountyAnimProxy: ref<inkAnimProxy>;

  private let m_animOptionsLoop: inkAnimOptions;

  private let m_wantedLevel: Int32;

  private let m_rootWidget: wref<inkWidget>;

  @default(WantedBarGameController, 1.0f)
  private const let WANTED_TIER_1: Float;

  @default(WantedBarGameController, 0.1f)
  private const let WANTED_MIN: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_wantedBlackboardDef = GetAllBlackboardDefs().UI_WantedBar;
    this.m_wantedBlackboard = this.GetBlackboardSystem().Get(this.m_wantedBlackboardDef);
    this.m_wantedCallbackID = this.m_wantedBlackboard.RegisterListenerInt(this.m_wantedBlackboardDef.CurrentWantedLevel, this, n"OnWantedDataChange");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_wantedBlackboard.UnregisterDelayedListener(this.m_wantedBlackboardDef.CurrentWantedLevel, this.m_wantedCallbackID);
  }

  protected cb func OnWantedDataChange(value: Int32) -> Bool {
    if !this.m_rootWidget.IsVisible() {
      this.m_animProxy = this.PlayLibraryAnimation(n"stars_intro");
      this.m_attentionAnimProxy = this.PlayLibraryAnimation(n"crime_reported");
    };
    if this.m_rootWidget.IsVisible() {
      this.m_attentionAnimProxy = this.PlayLibraryAnimation(n"crime_reported");
    };
    this.UpdateWantedData(value);
  }

  public final func UpdateWantedData(newWantedLevel: Int32) -> Void {
    let count: Int32;
    let i: Int32;
    let newWantedLevelReached: Bool = false;
    if this.m_wantedLevel != newWantedLevel {
      this.m_wantedLevel = newWantedLevel;
      newWantedLevelReached = true;
    };
    count = ArraySize(this.starsWidget);
    i;
    while i < count {
      if i < this.m_wantedLevel {
        (inkWidgetRef.GetController(this.starsWidget[i]) as StarController).SetBounty(true);
      } else {
        if i <= this.m_wantedLevel {
          if newWantedLevelReached {
            this.m_bountyAnimProxy.Stop();
            this.m_bountyAnimProxy = this.PlayLibraryAnimation(n"bounty_intro" + StringToName(ToString(i)));
          };
        } else {
          (inkWidgetRef.GetController(this.starsWidget[i]) as StarController).SetBounty(false);
        };
      };
      i += 1;
    };
    this.m_rootWidget.SetVisible(this.m_wantedLevel > 0);
  }

  public final func FlashAndHide() -> Void {
    this.m_bountyAnimProxy.Stop();
    if this.m_rootWidget.IsVisible() {
      this.m_bountyAnimProxy = this.PlayLibraryAnimation(n"flash_and_hide");
      this.m_bountyAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnWantedBarHidden");
    };
  }

  public final func StartFlash() -> Void {
    this.m_bountyAnimProxy.Stop();
    this.m_animOptionsLoop.loopInfinite = true;
    this.m_animOptionsLoop.loopType = inkanimLoopType.Cycle;
    this.m_bountyAnimProxy = this.PlayLibraryAnimation(n"flash", this.m_animOptionsLoop);
  }

  public final func EndFlash() -> Void {
    this.m_bountyAnimProxy.Stop();
    this.m_animOptionsLoop.loopInfinite = false;
    this.m_animOptionsLoop.loopType = inkanimLoopType.Cycle;
    this.m_bountyAnimProxy = this.PlayLibraryAnimation(n"flash", this.m_animOptionsLoop);
    this.m_bountyAnimProxy.Stop();
  }

  public final func FlashAndShow() -> Void {
    this.m_bountyAnimProxy.Stop();
    this.m_bountyAnimProxy = this.PlayLibraryAnimation(n"stars_intro");
  }

  protected cb func OnWantedBarHidden(animationProxy: ref<inkAnimProxy>) -> Bool {
    this.m_bountyAnimProxy.Stop();
    this.m_rootWidget.SetVisible(false);
  }

  protected cb func OnWantedBarStartFlashEvent(evt: ref<WantedBarStartFlashEvent>) -> Bool {
    this.StartFlash();
  }

  protected cb func OnWantedBarEndFlashEventEvent(evt: ref<WantedBarEndFlashEvent>) -> Bool {
    this.EndFlash();
  }

  protected cb func OnWantedBarFlashAndHideEventEvent(evt: ref<WantedBarFlashAndHideEvent>) -> Bool {
    this.FlashAndHide();
  }

  protected cb func OnWantedBarFlashAndShowEvent(evt: ref<WantedBarFlashAndShowEvent>) -> Bool {
    this.FlashAndShow();
  }

  public final static func FlashWantedBar(context: GameInstance) -> Void {
    let evt: ref<WantedBarStartFlashEvent>;
    if GameInstance.IsValid(context) {
      evt = new WantedBarStartFlashEvent();
      GameInstance.GetPlayerSystem(context).GetLocalPlayerControlledGameObject().QueueEvent(evt);
    };
  }

  public final static func EndFlashWantedBar(context: GameInstance) -> Void {
    let evt: ref<WantedBarEndFlashEvent>;
    if GameInstance.IsValid(context) {
      evt = new WantedBarEndFlashEvent();
      GameInstance.GetPlayerSystem(context).GetLocalPlayerControlledGameObject().QueueEvent(evt);
    };
  }

  public final static func FlashAndHideWantedBar(context: GameInstance) -> Void {
    let evt: ref<WantedBarFlashAndHideEvent>;
    if GameInstance.IsValid(context) {
      evt = new WantedBarFlashAndHideEvent();
      GameInstance.GetPlayerSystem(context).GetLocalPlayerControlledGameObject().QueueEvent(evt);
    };
  }

  public final static func FlashAndShowWantedBar(context: GameInstance) -> Void {
    let evt: ref<WantedBarFlashAndShowEvent>;
    if GameInstance.IsValid(context) {
      evt = new WantedBarFlashAndShowEvent();
      GameInstance.GetPlayerSystem(context).GetLocalPlayerControlledGameObject().QueueEvent(evt);
    };
  }
}

public class StarController extends inkLogicController {

  private edit let bountyBadgeWidget: inkWidgetRef;

  public final func SetBounty(arg: Bool) -> Void {
    inkWidgetRef.SetVisible(this.bountyBadgeWidget, arg);
  }
}

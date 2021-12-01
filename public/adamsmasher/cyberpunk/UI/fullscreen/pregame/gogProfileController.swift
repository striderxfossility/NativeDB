
public class GOGProfileGameController extends BaseGOGProfileController {

  public edit let m_retryButton: inkWidgetRef;

  public edit let m_parentContainerWidget: inkWidgetRef;

  private let isFirstLogin: Bool;

  private let showingFirstLogin: Bool;

  private let canRetry: Bool;

  protected cb func OnInitialize() -> Bool {
    this.isFirstLogin = false;
    this.showingFirstLogin = false;
    this.canRetry = false;
    inkWidgetRef.RegisterToCallback(this.m_retryButton, n"OnRelease", this, n"OnRetry");
    this.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnButtonRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.ShowRetryButton(false);
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_retryButton, n"OnRelease", this, n"OnRetry");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.GetRootWidget().UnregisterFromCallback(n"OnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnRetry(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      e.Handle();
      this.HandleRetry();
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsHandled() {
      return false;
    };
    if evt.IsAction(n"next_menu") {
      this.PlaySound(n"Button", n"OnPress");
      evt.Handle();
      this.HandleClose();
    } else {
      if this.canRetry && evt.IsAction(n"activate") {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.HandleRetry();
      };
    };
  }

  private final func HandleClose() -> Void {
    if this.showingFirstLogin && this.isFirstLogin {
      this.HidePreviousWidget();
      this.ShowRewards();
      this.showingFirstLogin = false;
      this.isFirstLogin = false;
    } else {
      this.RequestStop();
    };
  }

  private final func HandleRetry() -> Void {
    this.canRetry = false;
    GetGOGRewardsSystem().RequestInitialStatus();
  }

  private final func HidePreviousWidget() -> Void {
    let compoundParent: wref<inkCompoundWidget> = inkWidgetRef.Get(this.m_parentContainerWidget) as inkCompoundWidget;
    compoundParent.RemoveAllChildren();
    this.ShowRetryButton(false);
  }

  protected cb func OnRefreshGOGState(evt: ref<RefreshGOGState>) -> Bool {
    this.HidePreviousWidget();
    if NotEquals(evt.error, IntEnum(0l)) {
      this.ShowError(evt.error);
    } else {
      if Equals(evt.status, GOGRewardsSystemStatus.Registered) {
        if this.isFirstLogin {
          this.ShowThanks();
          this.showingFirstLogin = true;
        } else {
          this.ShowRewards();
        };
      } else {
        if Equals(evt.status, GOGRewardsSystemStatus.RegistrationPending) {
          this.ShowRegister(evt.registerURL, evt.qrCodePNGBlob);
        } else {
          this.ShowLoading();
        };
      };
    };
  }

  protected cb func OnLinkClicked(evt: ref<LinkClickedEvent>) -> Bool;

  private final func IsErrorRetryable(error: GOGRewardsSystemErrors) -> Bool {
    switch error {
      case GOGRewardsSystemErrors.RequestFailed:
        return false;
      case GOGRewardsSystemErrors.NoInternetConnection:
      case GOGRewardsSystemErrors.TemporaryFailure:
        return true;
    };
    return false;
  }

  private final func ShowError(error: GOGRewardsSystemErrors) -> Void {
    let controller: ref<GogErrorNotificationController> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_parentContainerWidget), n"ErrorNotification").GetController() as GogErrorNotificationController;
    controller.ShowErrorMessage(error);
    this.canRetry = this.IsErrorRetryable(error);
    this.ShowRetryButton(this.canRetry);
  }

  private final func ShowThanks() -> Void {
    this.SpawnFromLocal(inkWidgetRef.Get(this.m_parentContainerWidget), n"ThanksWidget");
  }

  private final func ShowLoading() -> Void {
    this.SpawnFromLocal(inkWidgetRef.Get(this.m_parentContainerWidget), n"LoadingWidget");
  }

  private final func ShowRewards() -> Void {
    let rewardsWidget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_parentContainerWidget), n"GOGRewardsWidget");
    let rewardsController: wref<GogRewardsController> = rewardsWidget.GetController() as GogRewardsController;
    if IsDefined(rewardsController) {
      rewardsController.UpdateRewardsList();
    };
  }

  private final func ShowRegister(registerUrl: String, qrCodePNGBlob: array<Uint8>) -> Void {
    let registerWidget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_parentContainerWidget), n"RegisterWidget");
    let registerController: wref<GogRegisterController> = registerWidget.GetController() as GogRegisterController;
    if IsDefined(registerController) {
      registerController.UpdateRegistrationData(registerUrl, qrCodePNGBlob);
      registerController.RegisterToCallback(n"OnLinkClickedEvent", this, n"OnLinkClicked");
    };
    this.isFirstLogin = true;
  }

  private final func ShowRetryButton(show: Bool) -> Void {
    let widget: ref<inkWidget> = inkWidgetRef.Get(this.m_retryButton);
    widget.SetVisible(show);
  }
}

public class GogRegisterController extends BaseGOGRegisterController {

  public edit let m_linkWidget: inkWidgetRef;

  public edit let m_qrImageWidget: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_linkWidget, n"OnRelease", this, n"OnLinkClicked");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_linkWidget, n"OnRelease", this, n"OnLinkClicked");
  }

  protected cb func OnLinkClicked(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.QueueEvent(new LinkClickedEvent());
    };
  }

  public final func UpdateRegistrationData(registerUrl: String, qrCodePNGBlob: array<Uint8>) -> Void {
    let qrImageWidget: ref<inkImage>;
    let linkWidget: ref<inkText> = inkWidgetRef.Get(this.m_linkWidget) as inkText;
    if IsDefined(linkWidget) {
      linkWidget.SetText(registerUrl);
    };
    qrImageWidget = inkWidgetRef.Get(this.m_qrImageWidget) as inkImage;
    if IsDefined(qrImageWidget) {
      this.SetupQRCodeWidget(qrImageWidget, qrCodePNGBlob);
    };
  }
}

public class GogRewardsController extends inkLogicController {

  public edit let m_containerWidget: inkWidgetRef;

  public final func UpdateRewardsList() -> Void {
    let count: Int32;
    let entryController: wref<GogRewardEntryController>;
    let i: Int32;
    let rewards: array<GOGRewardPack>;
    let compoundParent: wref<inkCompoundWidget> = inkWidgetRef.Get(this.m_containerWidget) as inkCompoundWidget;
    compoundParent.RemoveAllChildren();
    rewards = GetGOGRewardsSystem().GetUnlockedRewardPacks();
    count = ArraySize(rewards);
    i = 0;
    while i < count {
      entryController = this.SpawnFromLocal(compoundParent, n"RewardEntry").GetController() as GogRewardEntryController;
      entryController.UpdateRewardDetails(rewards[i].title, rewards[i].reason, rewards[i].iconSlot);
      i += 1;
    };
  }
}

public class GogRewardEntryController extends inkLogicController {

  public edit let m_nameWidget: inkWidgetRef;

  public edit let m_descriptionWidget: inkWidgetRef;

  public edit let m_iconImage: inkImageRef;

  public final func UpdateRewardDetails(rewardTitle: String, rewardDescription: String, iconSlot: CName) -> Void {
    let descriptionWidget: ref<inkText>;
    let nameWidget: ref<inkText> = inkWidgetRef.Get(this.m_nameWidget) as inkText;
    if IsDefined(nameWidget) {
      nameWidget.SetText(rewardTitle);
    };
    descriptionWidget = inkWidgetRef.Get(this.m_descriptionWidget) as inkText;
    if IsDefined(descriptionWidget) {
      descriptionWidget.SetText(rewardDescription);
    };
    if IsDefined(inkWidgetRef.Get(this.m_iconImage)) {
      inkImageRef.SetTexturePart(this.m_iconImage, iconSlot);
    };
  }
}

public class GogErrorNotificationController extends inkLogicController {

  public edit let m_errorMessageWidget: inkWidgetRef;

  public final func ShowErrorMessage(error: GOGRewardsSystemErrors) -> Void {
    let errorMessageText: ref<inkText> = inkWidgetRef.Get(this.m_errorMessageWidget) as inkText;
    errorMessageText.SetLocalizedText(StringToName(GOGRewardSystemErrorToDisplayString(error)));
  }
}

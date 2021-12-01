
public native class TutorialPopupGameController extends inkGameController {

  public edit let m_actionHint: inkWidgetRef;

  public edit let m_popupPanel: inkWidgetRef;

  public edit let m_popupFullscreenPanel: inkWidgetRef;

  public edit let m_popupBlockingPanel: inkWidgetRef;

  public edit let m_popupFullscreenRightPanel: inkWidgetRef;

  private let m_data: wref<TutorialPopupData>;

  private let m_inputBlocked: Bool;

  private let m_gamePaused: Bool;

  private let m_isShownBbId: ref<CallbackHandle>;

  @default(TutorialPopupGameController, into_popup)
  private let m_animIntroPopup: CName;

  @default(TutorialPopupGameController, into_popup_modal)
  private let m_animIntroPopupModal: CName;

  @default(TutorialPopupGameController, into_fullscreen_left)
  private let m_animIntroFullscreenLeft: CName;

  @default(TutorialPopupGameController, into_fullscreen_right)
  private let m_animIntroFullscreenRight: CName;

  @default(TutorialPopupGameController, outro_popup)
  private let m_animOutroPopup: CName;

  @default(TutorialPopupGameController, outro_popup_modal)
  private let m_animOutroPopupModal: CName;

  @default(TutorialPopupGameController, outro_fullscreen_left)
  private let m_animOutroFullscreenLeft: CName;

  @default(TutorialPopupGameController, outro_fullscreen_right)
  private let m_animOutroFullscreenRight: CName;

  private let m_animIntro: CName;

  private let m_animOutro: CName;

  private let m_targetPopup: inkWidgetRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_targetPosition: PopupPosition;

  private final native func RequestVisualState() -> Void;

  private final native func RestorePreviousVisualState() -> Void;

  private final native func AdaptToScreenComposition() -> Void;

  protected cb func OnInitialize() -> Bool {
    this.RequestVisualState();
    this.m_data = this.GetRootWidget().GetUserData(n"TutorialPopupData") as TutorialPopupData;
    if this.m_data.closeAtInput {
      this.BlockInput(true);
    };
    if this.m_data.pauseGame {
      this.PauseGame(true);
      this.PlaySound(n"GameMenu", n"OnOpen");
    };
    this.SetupView();
  }

  protected cb func OnUninitialize() -> Bool {
    this.RestorePreviousVisualState();
    if this.m_inputBlocked {
      this.BlockInput(false);
    };
    if this.m_gamePaused {
      this.PauseGame(false);
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"close_tutorial") {
      if this.m_animationProxy != null {
        this.m_animationProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
        this.m_animationProxy.Stop();
        this.m_animationProxy = null;
      };
      this.m_animationProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(this.m_animOutro, inkWidgetRef.Get(this.m_targetPopup));
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutro");
      this.PlaySound(n"GameMenu", n"OnClose");
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let owner: ref<GameObject>;
    if this.m_inputBlocked {
      owner = this.GetPlayerControlledObject();
      owner.RegisterInputListener(this, n"UI_Apply");
      owner.RegisterInputListener(this, n"UI_Cancel");
      owner.RegisterInputListener(this, n"ChoiceApply");
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    if this.m_inputBlocked {
      this.GetPlayerControlledObject().UnregisterInputListener(this);
    };
  }

  private final func BlockInput(value: Bool) -> Void {
    if NotEquals(this.m_inputBlocked, value) {
      this.m_inputBlocked = value;
      if this.m_inputBlocked {
        this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
      } else {
        this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
      };
    };
  }

  private final func PauseGame(value: Bool) -> Void {
    if NotEquals(this.m_gamePaused, value) {
      this.m_gamePaused = value;
      if value {
        GameInstance.GetTimeSystem(this.GetPlayerControlledObject().GetGame()).SetTimeDilation(n"UI_TutorialPopup", 0.00);
        GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"global_tutorial_open");
      } else {
        GameInstance.GetTimeSystem(this.GetPlayerControlledObject().GetGame()).UnsetTimeDilation(n"UI_TutorialPopup");
        GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_menu_tutorial_close");
        GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"global_tutorial_close");
      };
    };
  }

  private final func SetupView() -> Void {
    let displayController: ref<TutorialPopupDisplayController>;
    let targetMargin: inkMargin;
    this.GetRootWidget().SetVisible(true);
    inkWidgetRef.SetVisible(this.m_popupPanel, false);
    inkWidgetRef.SetVisible(this.m_popupFullscreenPanel, false);
    inkWidgetRef.SetVisible(this.m_popupBlockingPanel, false);
    inkWidgetRef.SetVisible(this.m_popupFullscreenRightPanel, false);
    if this.m_animationProxy != null {
      this.m_animationProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      this.m_animationProxy.Stop();
      this.m_animationProxy = null;
    };
    if this.m_data.isModal {
      if Equals(this.m_data.position, PopupPosition.UpperRight) || Equals(this.m_data.position, PopupPosition.LowerRight) {
        this.m_targetPopup = this.m_popupFullscreenRightPanel;
        this.m_animIntro = this.m_animIntroFullscreenRight;
        this.m_animOutro = this.m_animOutroFullscreenRight;
      } else {
        this.m_targetPopup = this.m_popupFullscreenPanel;
        this.m_animIntro = this.m_animIntroFullscreenLeft;
        this.m_animOutro = this.m_animOutroFullscreenLeft;
      };
      inkWidgetRef.SetVisible(this.m_targetPopup, true);
      targetMargin = inkWidgetRef.GetMargin(this.m_targetPopup);
      targetMargin.left += this.m_data.margin.left;
      targetMargin.top += this.m_data.margin.top;
      targetMargin.right += this.m_data.margin.right;
      targetMargin.bottom += this.m_data.margin.bottom;
      inkWidgetRef.SetMargin(this.m_targetPopup, targetMargin);
    } else {
      if this.m_data.closeAtInput {
        this.m_targetPopup = this.m_popupBlockingPanel;
        this.m_animIntro = this.m_animIntroPopupModal;
        this.m_animOutro = this.m_animOutroPopupModal;
      } else {
        this.m_targetPopup = this.m_popupPanel;
        this.m_animIntro = this.m_animIntroPopup;
        this.m_animOutro = this.m_animOutroPopup;
      };
      inkWidgetRef.SetVisible(this.m_targetPopup, true);
      targetMargin = inkWidgetRef.GetMargin(this.m_targetPopup);
      targetMargin.left += this.m_data.margin.left;
      targetMargin.top += this.m_data.margin.top;
      targetMargin.right += this.m_data.margin.right;
      targetMargin.bottom += this.m_data.margin.bottom;
      inkWidgetRef.SetMargin(this.m_targetPopup, targetMargin);
      this.m_targetPosition = this.m_data.position;
      switch this.m_targetPosition {
        case PopupPosition.UpperRight:
          inkWidgetRef.SetAnchorPoint(this.m_targetPopup, 1.00, 0.00);
          inkWidgetRef.SetAnchor(this.m_targetPopup, inkEAnchor.TopRight);
          break;
        case PopupPosition.UpperLeft:
          inkWidgetRef.SetAnchorPoint(this.m_targetPopup, 0.00, 0.00);
          inkWidgetRef.SetAnchor(this.m_targetPopup, inkEAnchor.TopLeft);
          break;
        case PopupPosition.LowerLeft:
          inkWidgetRef.SetAnchorPoint(this.m_targetPopup, 0.00, 1.00);
          inkWidgetRef.SetAnchor(this.m_targetPopup, inkEAnchor.BottomLeft);
          break;
        case PopupPosition.LowerRight:
          inkWidgetRef.SetAnchorPoint(this.m_targetPopup, 1.00, 1.00);
          inkWidgetRef.SetAnchor(this.m_targetPopup, inkEAnchor.BottomRight);
          break;
        case PopupPosition.Center:
        case PopupPosition.Undefined:
          inkWidgetRef.SetAnchorPoint(this.m_targetPopup, 0.50, 0.50);
          inkWidgetRef.SetAnchor(this.m_targetPopup, inkEAnchor.Centered);
      };
    };
    displayController = inkWidgetRef.GetController(this.m_targetPopup) as TutorialPopupDisplayController;
    displayController.SetData(this.m_data);
    this.AdaptToScreenComposition();
    this.m_animationProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(this.m_animIntro, inkWidgetRef.Get(this.m_targetPopup));
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntro");
  }

  private final func AdaptToBlackBars(offset: Float) -> Void {
    let popupTranslation: Vector2 = inkWidgetRef.GetTranslation(this.m_targetPopup);
    switch this.m_targetPosition {
      case PopupPosition.LowerLeft:
      case PopupPosition.UpperLeft:
        popupTranslation.X += offset;
        inkWidgetRef.SetTranslation(this.m_targetPopup, popupTranslation);
        break;
      case PopupPosition.UpperRight:
      case PopupPosition.LowerRight:
        popupTranslation.X -= offset;
        inkWidgetRef.SetTranslation(this.m_targetPopup, popupTranslation);
        break;
      case PopupPosition.Center:
      case PopupPosition.Undefined:
        return;
    };
  }

  protected cb func OnIntro(anim: ref<inkAnimProxy>) -> Bool {
    if this.m_gamePaused {
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_menu_tutorial_open");
    };
  }

  protected cb func OnOutro(anim: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_data);
  }
}

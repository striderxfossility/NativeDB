
public class HudPhoneAvatarController extends HUDPhoneElement {

  private edit let m_ContactAvatar: inkImageRef;

  private edit let m_HolocallRenderTexture: inkImageRef;

  private edit let m_SignalRangeIcon: inkImageRef;

  private edit let m_ContactName: inkTextRef;

  private edit let m_StatusText: inkTextRef;

  private edit let m_WaveformPlaceholder: inkCanvasRef;

  private edit let m_HolocallHolder: inkFlexRef;

  @default(HudPhoneAvatarController, Unknown)
  private edit let m_UnknownAvatarName: CName;

  private edit let m_DefaultPortraitColor: Color;

  private edit let m_DefaultImageSize: Vector2;

  @default(HudPhoneAvatarController, avatarHoloCallLoopAnimation)
  private edit let m_LoopAnimationName: CName;

  @default(HudPhoneAvatarController, portraitIntro)
  private edit let m_ShowingAnimationName: CName;

  @default(HudPhoneAvatarController, portraitOutro)
  private edit let m_HidingAnimationName: CName;

  @default(HudPhoneAvatarController, avatarAudiocallShowingAnimation)
  private edit let m_AudiocallShowingAnimationName: CName;

  @default(HudPhoneAvatarController, avatarAudiocallHidingAnimation)
  private edit let m_AudiocallHidingAnimationName: CName;

  @default(HudPhoneAvatarController, avatarHolocallShowingAnimation)
  private edit let m_HolocallShowingAnimationName: CName;

  @default(HudPhoneAvatarController, avatarHolocallHidingAnimation)
  private edit let m_HolocallHidingAnimationName: CName;

  private let m_LoopAnimation: ref<inkAnimProxy>;

  private let options: inkAnimOptions;

  private let m_JournalManager: ref<IJournalManager>;

  private let m_RootAnimation: ref<inkAnimProxy>;

  private let m_AudiocallAnimation: ref<inkAnimProxy>;

  private let m_HolocallAnimation: ref<inkAnimProxy>;

  private let m_Holder: inkWidgetRef;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_CurrentMode: EHudAvatarMode;

  @default(HudPhoneAvatarController, false)
  private let m_Minimized: Bool;

  protected cb func OnInitialize() -> Bool {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let placeholder: inkWidgetRef;
    super.OnInitialize();
    placeholder = this.m_WaveformPlaceholder;
    this.SpawnFromLocal(inkWidgetRef.Get(placeholder), n"waveform");
    this.m_alpha_fadein = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(3.00);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.options.loopType = inkanimLoopType.Cycle;
    this.options.loopInfinite = true;
  }

  public final func SetJournalManager(journalManager: ref<IJournalManager>) -> Void {
    this.m_JournalManager = journalManager;
  }

  public final func SetHolder(holder: inkWidgetRef) -> Void {
    this.m_Holder = holder;
  }

  public final func ShowIncomingContact(contactToShow: wref<JournalContact>) -> Void {
    this.RefreshView(contactToShow, EHudAvatarMode.Connecting);
  }

  public final func ShowEndCallContact(contactToShow: wref<JournalContact>) -> Void {
    if Equals(this.m_CurrentMode, EHudAvatarMode.Holocall) || Equals(this.m_CurrentMode, EHudAvatarMode.Audiocall) {
      this.m_Minimized = false;
      this.RefreshView(contactToShow, EHudAvatarMode.Disconnecting);
    } else {
      this.Hide();
    };
  }

  public final func StartAudiocall(contactToShow: wref<JournalContact>) -> Void {
    this.RefreshView(contactToShow, EHudAvatarMode.Audiocall);
  }

  public final func StartHolocall(contactToShow: wref<JournalContact>) -> Void {
    this.RefreshView(contactToShow, EHudAvatarMode.Holocall);
  }

  public final func ChangeMinimized(minimized: Bool) -> Void {
    if NotEquals(minimized, this.m_Minimized) {
      this.m_Minimized = minimized;
      inkWidgetRef.SetVisible(this.m_SignalRangeIcon, Equals(this.m_CurrentMode, EHudAvatarMode.Audiocall) || this.m_Minimized);
      inkWidgetRef.SetVisible(this.m_WaveformPlaceholder, Equals(this.m_CurrentMode, EHudAvatarMode.Audiocall) || this.m_Minimized);
      this.PlayElementAnimations();
    };
  }

  public final func SetStatusText(statusText: String) -> Void {
    inkTextRef.SetLetterCase(this.m_StatusText, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_StatusText, statusText);
  }

  protected cb func OnStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool {
    let currentState: EHudPhoneVisibility;
    this.StopRootAnimation();
    currentState = this.GetStateFromName(newState);
    if Equals(currentState, EHudPhoneVisibility.Showing) {
      this.m_RootAnimation = this.PlayLibraryAnimation(this.m_ShowingAnimationName);
      this.m_RootAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnRootAnimationFinished");
    } else {
      if Equals(currentState, EHudPhoneVisibility.Visible) {
        this.m_RootWidget.SetOpacity(1.00);
        if !this.m_LoopAnimation.IsPlaying() {
          this.m_LoopAnimation = this.PlayLibraryAnimation(this.m_LoopAnimationName, this.options);
        };
      } else {
        if Equals(currentState, EHudPhoneVisibility.Hiding) {
          this.m_LoopAnimation.Stop();
          this.m_RootAnimation = this.PlayLibraryAnimation(this.m_HidingAnimationName);
          this.m_RootAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnRootAnimationFinished");
        } else {
          if Equals(currentState, EHudPhoneVisibility.Invisible) {
            this.m_RootWidget.SetOpacity(0.00);
            inkWidgetRef.SetTintColor(this.m_ContactAvatar, this.m_DefaultPortraitColor);
            inkWidgetRef.SetSize(this.m_ContactAvatar, this.m_DefaultImageSize);
            inkWidgetRef.SetSize(this.m_HolocallRenderTexture, this.m_DefaultImageSize);
          };
        };
      };
    };
  }

  private final func RefreshView(contact: wref<JournalContact>, mode: EHudAvatarMode) -> Void {
    let statusText: String;
    if IsDefined(contact) {
      this.m_CurrentMode = mode;
      inkWidgetRef.SetVisible(this.m_ContactAvatar, Equals(mode, EHudAvatarMode.Connecting));
      InkImageUtils.RequestSetImage(this, this.m_ContactAvatar, contact.GetAvatarID(this.m_JournalManager));
      inkTextRef.SetLetterCase(this.m_ContactName, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_ContactName, contact.GetLocalizedName(this.m_JournalManager));
      inkWidgetRef.SetVisible(this.m_SignalRangeIcon, Equals(mode, EHudAvatarMode.Audiocall) || this.m_Minimized);
      inkWidgetRef.SetVisible(this.m_WaveformPlaceholder, Equals(mode, EHudAvatarMode.Audiocall) || this.m_Minimized);
      inkWidgetRef.SetVisible(this.m_HolocallRenderTexture, Equals(mode, EHudAvatarMode.Holocall));
      switch mode {
        case EHudAvatarMode.Connecting:
          statusText = "Connecting";
          inkWidgetRef.SetOpacity(this.m_Holder, 1.00);
          break;
        case EHudAvatarMode.Disconnecting:
          statusText = "Disconnecting";
          break;
        case EHudAvatarMode.Holocall:
          statusText = this.m_Minimized ? "Connection Status: Active Voice Call" : "Connection 541.44.10";
          break;
        case EHudAvatarMode.Audiocall:
          statusText = "Connection Status: Active Voice Call";
          break;
        default:
          statusText = "Connected";
      };
      this.SetStatusText(statusText);
      this.Show();
      this.PlayElementAnimations();
      inkWidgetRef.SetVisible(this.m_HolocallHolder, !this.m_Minimized);
    };
  }

  private final func StopRootAnimation() -> Void {
    if IsDefined(this.m_RootAnimation) {
      this.m_RootAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
      this.m_RootAnimation.Stop();
      this.m_RootAnimation = null;
    };
  }

  private final func StopAudiocallAnimation() -> Void {
    if IsDefined(this.m_AudiocallAnimation) {
      this.m_AudiocallAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAudiocallAnimationFinished");
      this.m_AudiocallAnimation.Stop();
      this.m_AudiocallAnimation = null;
    };
  }

  private final func StopHolocallAnimation() -> Void {
    if IsDefined(this.m_HolocallAnimation) {
      this.m_HolocallAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHolocallAnimationFinished");
      this.m_HolocallAnimation.Stop();
      this.m_HolocallAnimation = null;
    };
  }

  private final func PlayElementAnimations() -> Void {
    let animationName: CName;
    let isAudiocall: Bool;
    let isHolocall: Bool;
    let isMinimized: Bool;
    let showAvatar: Bool;
    this.StopAudiocallAnimation();
    this.StopHolocallAnimation();
    isMinimized = this.m_Minimized;
    showAvatar = Equals(this.m_CurrentMode, EHudAvatarMode.Connecting);
    isHolocall = Equals(this.m_CurrentMode, EHudAvatarMode.Holocall);
    isAudiocall = Equals(this.m_CurrentMode, EHudAvatarMode.Audiocall);
    animationName = showAvatar || isHolocall && !isMinimized ? this.m_HolocallShowingAnimationName : this.m_HolocallHidingAnimationName;
    this.m_HolocallAnimation = this.PlayLibraryAnimation(animationName);
    this.m_HolocallAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHolocallAnimationFinished");
    animationName = isAudiocall || isMinimized ? this.m_AudiocallShowingAnimationName : this.m_AudiocallHidingAnimationName;
    this.m_AudiocallAnimation = this.PlayLibraryAnimation(animationName);
    this.m_AudiocallAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAudiocallAnimationFinished");
  }

  private final func AreElementAnimationsComplete() -> Bool {
    return !(!(IsDefined(this.m_AudiocallAnimation) && this.m_AudiocallAnimation.IsPlaying()) && !(IsDefined(this.m_HolocallAnimation) && this.m_HolocallAnimation.IsPlaying()));
  }

  protected cb func OnHolocallAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.StopHolocallAnimation();
    this.OnElementAnimationsFinished();
  }

  protected cb func OnAudiocallAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.StopAudiocallAnimation();
    this.OnElementAnimationsFinished();
  }

  private final func OnElementAnimationsFinished() -> Void {
    if this.AreElementAnimationsComplete() {
      if Equals(this.m_CurrentMode, EHudAvatarMode.Disconnecting) {
        inkWidgetRef.SetOpacity(this.m_Holder, 0.00);
        this.Hide();
      };
    };
  }

  protected cb func OnRootAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    let currentState: EHudPhoneVisibility;
    this.StopRootAnimation();
    currentState = this.GetState();
    if Equals(currentState, EHudPhoneVisibility.Showing) {
      this.SetState(EHudPhoneVisibility.Visible);
    } else {
      if Equals(currentState, EHudPhoneVisibility.Hiding) {
        this.SetState(EHudPhoneVisibility.Invisible);
      };
    };
  }
}

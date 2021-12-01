
public class DeviceButtonLogicControllerBase extends inkButtonController {

  @attrib(category, "Widget Refs")
  protected edit let m_targetWidgetRef: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_displayNameWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_iconWidget: inkImageRef;

  @attrib(category, "Widget Refs")
  protected edit let m_toggleSwitchWidget: inkImageRef;

  @attrib(category, "Widget Refs")
  protected edit let m_sizeProviderWidget: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_selectionMarkerWidget: inkWidgetRef;

  @attrib(category, "Animations")
  protected inline edit let m_onReleaseAnimations: ref<WidgetAnimationManager>;

  @attrib(category, "Animations")
  protected inline edit let m_onPressAnimations: ref<WidgetAnimationManager>;

  @attrib(category, "Animations")
  protected inline edit let m_onHoverOverAnimations: ref<WidgetAnimationManager>;

  @attrib(category, "Animations")
  protected inline edit let m_onHoverOutAnimations: ref<WidgetAnimationManager>;

  @attrib(category, "Style Overrides")
  protected edit let m_defaultStyle: ResRef;

  @attrib(category, "Style Overrides")
  protected edit let m_selectionStyle: ResRef;

  protected edit let m_soundData: SSoundData;

  protected let m_isInitialized: Bool;

  protected let m_targetWidget: wref<inkWidget>;

  protected let m_isSelected: Bool;

  protected cb func OnInitialize() -> Bool {
    if inkWidgetRef.Get(this.m_targetWidgetRef) == null {
      this.m_targetWidget = this.GetRootWidget();
    } else {
      this.m_targetWidget = inkWidgetRef.Get(this.m_targetWidgetRef);
    };
    this.RegisterBaseInputCallbacks();
    this.ResolveSelection();
  }

  public final func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }

  protected func ResolveWidgetState(state: EWidgetState) -> Void;

  public final func SetButtonSize(x: Float, y: Float) -> Void {
    inkWidgetRef.SetSize(this.m_sizeProviderWidget, x, y);
  }

  public func ToggleSelection(isSelected: Bool) -> Void {
    this.SetSelected(isSelected);
    this.ResolveSelection();
  }

  public func ResolveSelection() -> Void {
    if this.GetSelected() {
      inkWidgetRef.SetVisible(this.m_selectionMarkerWidget, true);
      if ResRef.IsValid(this.m_selectionStyle) {
        this.m_targetWidget.SetStyle(this.m_selectionStyle);
      };
    } else {
      inkWidgetRef.SetVisible(this.m_selectionMarkerWidget, false);
      if ResRef.IsValid(this.m_defaultStyle) {
        this.m_targetWidget.SetStyle(this.m_defaultStyle);
      };
    };
  }

  public func RegisterBaseInputCallbacks() -> Void {
    this.m_targetWidget.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.m_targetWidget.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.m_targetWidget.RegisterToCallback(n"OnPress", this, n"OnPress");
    this.m_targetWidget.RegisterToCallback(n"OnRelease", this, n"OnRelease");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.TriggerOnHoverOverAnimations();
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.TriggerOnHoverOutAnimations();
  }

  protected cb func OnPress(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.TriggerOnPressAnimations();
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.TriggerOnReleaseAnimations();
    };
  }

  private final func TriggerOnHoverOutAnimations() -> Void {
    if this.m_onHoverOutAnimations != null {
      this.m_onHoverOutAnimations.TriggerAnimations(this);
    };
  }

  private final func TriggerOnHoverOverAnimations() -> Void {
    if this.m_onHoverOverAnimations != null {
      this.m_onHoverOverAnimations.TriggerAnimations(this);
    };
  }

  private final func TriggerOnPressAnimations() -> Void {
    if this.m_onPressAnimations != null {
      this.m_onPressAnimations.TriggerAnimations(this);
    };
  }

  private final func TriggerOnReleaseAnimations() -> Void {
    if this.m_onReleaseAnimations != null {
      this.m_onReleaseAnimations.TriggerAnimations(this);
    };
  }

  public final func RegisterAudioCallbacks(gameController: ref<inkGameController>) -> Void {
    this.m_targetWidget.RegisterToCallback(n"OnHoverOver", gameController, n"OnButtonHoverOver");
    this.m_targetWidget.RegisterToCallback(n"OnHoverOut", gameController, n"OnButtonHoverOut");
    this.m_targetWidget.RegisterToCallback(n"OnPress", gameController, n"OnButtonPress");
  }

  public final func GetWidgetAudioName() -> CName {
    return this.m_soundData.widgetAudioName;
  }

  public final func GetOnPressKey() -> CName {
    return this.m_soundData.onPressKey;
  }

  public final func GetOnReleaseKey() -> CName {
    return this.m_soundData.onReleaseKey;
  }

  public final func GetOnHoverOverKey() -> CName {
    return this.m_soundData.onHoverOverKey;
  }

  public final func GetOnHoverOutKey() -> CName {
    return this.m_soundData.onHoverOutKey;
  }

  public final func ATUI_GetButtonDisplayText() -> String {
    return inkTextRef.GetText(this.m_displayNameWidget);
  }
}

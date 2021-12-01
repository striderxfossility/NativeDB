
public class sampleUILoadingBarController extends inkLogicController {

  public edit let minSize: Vector2;

  public edit let maxSize: Vector2;

  public edit let imageWidgetPath: CName;

  public edit let textWidgetPath: CName;

  private let m_currentSize: Vector2;

  private let m_imageWidget: wref<inkImage>;

  private let m_textWidget: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.m_imageWidget = this.GetWidget(this.imageWidgetPath) as inkImage;
    this.m_textWidget = this.GetWidget(this.textWidgetPath) as inkText;
    this.m_currentSize = this.minSize;
    this.m_imageWidget.SetSize(this.m_currentSize);
    this.m_textWidget.SetText("Waiting");
  }

  public final func OnHold(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.m_currentSize.X = this.minSize.X + (this.maxSize.X - this.minSize.X) * e.GetHoldProgress();
      this.m_imageWidget.SetSize(this.m_currentSize);
      this.m_textWidget.SetText(ToString(e.GetHoldProgress()));
    };
  }

  public final func OnRelease(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.m_textWidget.SetText("Waiting");
    };
  }
}

public class sampleUIEventTestLogicController extends inkLogicController {

  public edit let eventTextWidgetPath: CName;

  public edit let eventVerticalPanelPath: CName;

  public edit let callbackTextWidgetPath: CName;

  public edit let callbackVerticalPanelPath: CName;

  public edit let customCallbackName: CName;

  private let m_textWidget: wref<inkText>;

  private let m_verticalPanelWidget: wref<inkVerticalPanel>;

  private let m_isEnabled: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_isEnabled = true;
  }

  private final func ToggleVisibility(text: String) -> Void {
    if Equals(this.m_isEnabled, true) {
      this.m_isEnabled = false;
      this.m_textWidget.SetText("HIDDEN " + text);
      this.m_verticalPanelWidget.SetVisible(false);
    } else {
      this.m_isEnabled = true;
      this.m_textWidget.SetText("SHOWN " + text);
      this.m_verticalPanelWidget.SetVisible(true);
    };
  }

  public final func OnButtonClickEventTest(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.m_textWidget = this.GetWidget(this.callbackTextWidgetPath) as inkText;
      this.m_verticalPanelWidget = this.GetWidget(this.callbackVerticalPanelPath) as inkVerticalPanel;
      this.ToggleVisibility("(Callback test)");
    };
  }

  public final func CallbackTest(widget: wref<inkWidget>) -> Void {
    this.m_textWidget = this.GetWidget(this.eventTextWidgetPath) as inkText;
    this.m_verticalPanelWidget = this.GetWidget(this.eventVerticalPanelPath) as inkVerticalPanel;
    this.ToggleVisibility("(Event test)");
  }

  public final func OnButtonClickCallbackTest(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.GetWidget(this.callbackVerticalPanelPath).CallCustomCallback(this.customCallbackName);
    };
  }
}

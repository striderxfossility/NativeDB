
public class ImageSwappingController extends inkLogicController {

  public edit let ImageWidgetPath: String;

  public edit const let ButtonsPaths: array<CName>;

  public edit const let ButtonsNames: array<String>;

  public edit const let ButtonsValues: array<String>;

  private let Buttons: array<wref<inkCanvas>>;

  protected cb func OnInitialize() -> Bool {
    this.FillButtons();
  }

  private final func FillButtons() -> Void {
    let button: ref<inkCanvas>;
    let controller: wref<TechQA_ImageSwappingButtonController>;
    let i: Int32 = 0;
    while i < ArraySize(this.ButtonsPaths) {
      button = this.GetWidget(this.ButtonsPaths[i]) as inkCanvas;
      if IsDefined(button) {
        ArrayPush(this.Buttons, button);
        controller = button.GetController() as TechQA_ImageSwappingButtonController;
        if IsDefined(controller) {
          controller.SetDescription(this.ButtonsNames[i]);
        };
      };
      i += 1;
    };
  }
}

public class TechQA_ImageSwappingButtonController extends inkLogicController {

  public edit let textWidgetPath: CName;

  public let textWidget: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.textWidget = this.GetWidget(this.textWidgetPath) as inkText;
  }

  public final func SetDescription(newDescription: String) -> Void {
    this.textWidget.SetText(newDescription);
  }
}


public class sampleImageChanger extends inkLogicController {

  public edit let imagePath: CName;

  public edit let imageName_1: CName;

  public edit let imageName_2: CName;

  private let imageWidget: wref<inkImage>;

  protected cb func OnInitialize() -> Bool {
    this.imageWidget = this.GetWidget(this.imagePath) as inkImage;
  }

  public final func OnButtonClick(e: ref<inkPointerEvent>) -> Void {
    let buttonWidget: wref<inkWidget>;
    if e.IsAction(n"click") {
      buttonWidget = e.GetCurrentTarget();
      switch buttonWidget.GetName() {
        case n"Button1":
          this.ChangeImage(this.imageName_1);
          break;
        case n"Button2":
          this.ChangeImage(this.imageName_2);
      };
    };
  }

  private final func ChangeImage(imageName: CName) -> Void {
    this.imageWidget.SetTexturePart(imageName);
  }
}

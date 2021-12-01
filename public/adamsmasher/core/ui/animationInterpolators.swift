
public native class inkAnimColor extends inkAnimInterpolator {

  public final native func GetStartColor() -> Color;

  public final native func GetEndColor() -> Color;

  public final native func SetStartColor(startColor: HDRColor) -> Void;

  public final func SetStartColor(startColor: Color) -> Void {
    this.SetStartColor(Color.ToHDRColorDirect(startColor));
  }

  public final native func SetEndColor(endColor: HDRColor) -> Void;

  public final func SetEndColor(endColor: Color) -> Void {
    this.SetEndColor(Color.ToHDRColorDirect(endColor));
  }
}

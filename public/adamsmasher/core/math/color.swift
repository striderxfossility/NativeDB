
public native struct Color {

  public native let Red: Uint8;

  public native let Green: Uint8;

  public native let Blue: Uint8;

  public native let Alpha: Uint8;

  public final static func ToHDRColorDirect(color: Color) -> HDRColor {
    return new HDRColor(Cast(color.Red) / 255.00, Cast(color.Green) / 255.00, Cast(color.Blue) / 255.00, Cast(color.Alpha) / 255.00);
  }
}

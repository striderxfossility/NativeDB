
public struct SColor {

  public final static func Red(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(255u, 0u, 0u, value);
  }

  public final static func Green(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(0u, 255u, 0u, value);
  }

  public final static func Blue(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(0u, 0u, 255u, value);
  }

  public final static func White(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(255u, 255u, 255u, value);
  }

  public final static func Black(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(0u, 0u, 0u, value);
  }

  public final static func Grey(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(0u, 0u, 0u, value);
  }

  public final static func Yellow(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(255u, 215u, 0u, value);
  }

  public final static func Orange(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(255u, 140u, 0u, value);
  }

  public final static func Pink(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(255u, 20u, 147u, value);
  }

  public final static func Purple(opt alpha: Uint8) -> Color {
    let value: Uint8 = alpha == 0u ? 200u : alpha;
    return new Color(148u, 0u, 211u, value);
  }
}

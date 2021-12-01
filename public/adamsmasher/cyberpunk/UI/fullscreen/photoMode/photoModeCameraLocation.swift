
public class PhotoModeCameraLocation extends inkLogicController {

  public edit let m_textWidget: inkWidgetRef;

  public final func RefreshValue(photoModeSystem: ref<PhotoModeSystem>) -> Void {
    let cameraPosition: WorldPosition;
    let textWidget: ref<inkText>;
    photoModeSystem.GetCameraLocation(cameraPosition);
    textWidget = inkWidgetRef.Get(this.m_textWidget) as inkText;
    if IsDefined(textWidget) {
      textWidget.SetText("WPXYZ / " + FloatToStringPrec(WorldPosition.GetX(cameraPosition), 3) + " / " + FloatToStringPrec(WorldPosition.GetY(cameraPosition), 3) + " / " + FloatToStringPrec(WorldPosition.GetZ(cameraPosition), 3) + " / CP");
    };
  }

  public final func OnHide() -> Void {
    let textWidget: ref<inkText> = inkWidgetRef.Get(this.m_textWidget) as inkText;
    if IsDefined(textWidget) {
      textWidget.SetText("");
    };
  }
}

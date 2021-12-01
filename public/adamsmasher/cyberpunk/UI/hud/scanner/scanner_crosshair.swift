
public class ScannerCrosshairLogicController extends inkLogicController {

  private let m_rootWidget: wref<inkWidget>;

  private let m_projection: ref<inkScreenProjection>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 0.00));
  }

  public final func CreateProjectionData() -> inkScreenProjectionData {
    let projectionData: inkScreenProjectionData;
    projectionData.userData = this;
    projectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
    projectionData.slotComponentName = n"UI_Slots";
    projectionData.slotName = n"UI_Interaction";
    return projectionData;
  }

  public final func GetProjection() -> ref<inkScreenProjection> {
    return this.m_projection;
  }

  public final func SetProjection(projection: ref<inkScreenProjection>) -> Void {
    this.m_projection = projection;
  }

  public final func SetEntity(entityObject: wref<Entity>) -> Void {
    this.m_projection.SetEntity(entityObject);
  }

  public final func UpdateProjection() -> Void {
    let margin: inkMargin;
    if IsDefined(this.m_projection) {
      margin.left = this.m_projection.currentPosition.X;
      margin.top = this.m_projection.currentPosition.Y;
      this.m_rootWidget.SetMargin(margin);
    };
  }
}

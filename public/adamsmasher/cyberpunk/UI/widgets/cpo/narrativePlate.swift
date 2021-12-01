
public class NarrativePlateGameController extends inkProjectedHUDGameController {

  private edit let m_plateHolder: inkWidgetRef;

  private let m_projection: ref<inkScreenProjection>;

  private let m_narrativePlateBlackboard: wref<IBlackboard>;

  private let m_narrativePlateBlackboardText: ref<CallbackHandle>;

  private let m_logicController: wref<NarrativePlateLogicController>;

  protected cb func OnInitialize() -> Bool {
    let projectionData: inkScreenProjectionData;
    projectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
    projectionData.slotComponentName = n"UI_Slots";
    projectionData.slotName = n"NarrativePlate";
    this.m_projection = this.RegisterScreenProjection(projectionData);
    this.m_logicController = inkWidgetRef.GetController(this.m_plateHolder) as NarrativePlateLogicController;
    this.m_narrativePlateBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NarrativePlate);
    this.m_narrativePlateBlackboardText = this.m_narrativePlateBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_NarrativePlate.PlateData, this, n"OnNarrativePlateChanged");
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_narrativePlateBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_NarrativePlate.PlateData, this.m_narrativePlateBlackboardText);
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    if this.m_projection.GetEntity() != null {
      inkWidgetRef.SetMargin(this.m_plateHolder, new inkMargin(projections.data[0].currentPosition.X, projections.data[0].currentPosition.Y, 0.00, 0.00));
    } else {
      inkWidgetRef.SetMargin(this.m_plateHolder, new inkMargin(0.00, 0.00, 0.00, 0.00));
    };
  }

  protected cb func OnNarrativePlateChanged(value: Variant) -> Bool {
    let plateData: NarrativePlateData = FromVariant(value);
    this.m_projection.SetEntity(plateData.entity);
    this.m_logicController.SetVisible(plateData.entity != null);
    this.m_logicController.SetPlateText(plateData.text, plateData.caption);
  }
}

public class NarrativePlateLogicController extends inkLogicController {

  private edit let m_textWidget: inkWidgetRef;

  private edit let m_captionWidget: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  public final func SetPlateText(text: String, caption: String) -> Void {
    let textWidget: wref<inkText> = inkWidgetRef.Get(this.m_textWidget) as inkText;
    textWidget.SetText(text);
    textWidget = inkWidgetRef.Get(this.m_captionWidget) as inkText;
    textWidget.SetVisible(StrLen(caption) > 0);
    textWidget.SetText(caption);
  }

  public final func SetVisible(visible: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_root, visible);
  }
}

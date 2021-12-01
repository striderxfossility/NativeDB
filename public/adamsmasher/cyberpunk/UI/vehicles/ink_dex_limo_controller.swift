
public class inkDexLimoGameController extends inkGameController {

  private let m_activeVehicleBlackboard: wref<IBlackboard>;

  private let m_playerVehStateId: ref<CallbackHandle>;

  private let m_screenVideoWidget: wref<inkVideo>;

  private edit let m_screenVideoWidgetPath: CName;

  private edit let m_videoPath: ResRef;

  protected cb func OnInitialize() -> Bool {
    this.m_activeVehicleBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    if IsDefined(this.m_activeVehicleBlackboard) {
      this.m_playerVehStateId = this.m_activeVehicleBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this, n"OnPlayerStateChanged");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_activeVehicleBlackboard) {
      this.m_activeVehicleBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this.m_playerVehStateId);
    };
  }

  protected cb func OnPlayerStateChanged(data: Variant) -> Bool {
    let newData: VehEntityPlayerStateData = FromVariant(data);
    let vehEntityID: EntityID = newData.entID;
    let entID: EntityID = this.GetOwnerEntity().GetEntityID();
    let playerState: Int32 = newData.state;
    if entID == vehEntityID {
      this.m_screenVideoWidget = this.GetWidget(this.m_screenVideoWidgetPath) as inkVideo;
      if playerState > EnumInt(gamePSMVehicle.Default) {
        this.m_screenVideoWidget.SetVideoPath(this.m_videoPath);
        this.m_screenVideoWidget.SetLoop(true);
        this.m_screenVideoWidget.Play();
      } else {
        this.m_screenVideoWidget.Stop();
      };
    };
  }
}

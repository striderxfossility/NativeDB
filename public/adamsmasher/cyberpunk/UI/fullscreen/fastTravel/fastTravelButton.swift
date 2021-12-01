
public class FastTravelButtonLogicController extends inkButtonController {

  private edit let m_districtName: inkTextRef;

  private edit let m_locationName: inkTextRef;

  private edit let m_soundData: SSoundData;

  private let m_isInitialized: Bool;

  private let m_fastTravelPointData: wref<FastTravelPointData>;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool;

  public final func Initialize(data: ref<FastTravelPointData>) -> Void {
    this.m_fastTravelPointData = data;
    this.SetDescription(data);
    this.m_isInitialized = true;
  }

  public final func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }

  private final func SetDescription(data: ref<FastTravelPointData>) -> Void {
    let pointName: String = TweakDBInterface.GetFastTravelPointRecord(data.GetPointRecord()).DisplayName();
    let districtName: String = TweakDBInterface.GetFastTravelPointRecord(data.GetPointRecord()).District().EnumName();
    inkTextRef.SetText(this.m_districtName, districtName);
    inkTextRef.SetText(this.m_locationName, pointName);
  }

  public final const func GetFastTravelPointData() -> ref<FastTravelPointData> {
    return this.m_fastTravelPointData;
  }

  public final func RegisterAudioCallbacks(gameController: ref<inkGameController>) -> Void {
    this.RegisterToCallback(n"OnHoverOver", gameController, n"OnButtonHoverOver");
    this.RegisterToCallback(n"OnHoverOut", gameController, n"OnButtonHoverOut");
    this.RegisterToCallback(n"OnPress", gameController, n"OnButtonPress");
  }

  public final func GetWidgetAudioName() -> CName {
    return this.m_soundData.widgetAudioName;
  }

  public final func GetOnPressKey() -> CName {
    return this.m_soundData.onPressKey;
  }

  public final func GetOnReleaseKey() -> CName {
    return this.m_soundData.onReleaseKey;
  }

  public final func GetOnHoverOverKey() -> CName {
    return this.m_soundData.onHoverOverKey;
  }

  public final func GetOnHoverOutKey() -> CName {
    return this.m_soundData.onHoverOutKey;
  }
}

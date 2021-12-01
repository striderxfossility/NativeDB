
public class RemotePlayerMappinController extends BaseInteractionMappinController {

  private let m_mappin: wref<RemotePlayerMappin>;

  private let m_root: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin() as RemotePlayerMappin;
    this.m_root = this.GetRootWidget();
    this.OnUpdate();
  }

  protected cb func OnUpdate() -> Bool {
    this.SetRootVisible(this.m_mappin.vitals == EnumInt(gamePSMVitals.Dead));
  }
}

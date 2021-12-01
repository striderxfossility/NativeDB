
public class KillMarkerGameController extends inkGameController {

  private let m_targetNeutralized: ref<CallbackHandle>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_blackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Crosshair);
    this.m_targetNeutralized = this.m_blackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_Crosshair.EnemyNeutralized, this, n"OnNPCNeutralized");
    this.GetRootWidget().SetAnchor(inkEAnchor.Centered);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_Crosshair.EnemyNeutralized, this.m_targetNeutralized);
  }

  protected cb func OnNPCNeutralized(value: Variant) -> Bool {
    let incomingData: ENeutralizeType = FromVariant(value);
    if NotEquals(incomingData, IntEnum(0l)) && !this.m_animProxy.IsPlaying() {
      this.m_animProxy = this.PlayLibraryAnimation(n"anim_kill_marker");
      this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnKillMarkerComplete");
    };
  }

  protected cb func OnKillMarkerComplete(proxy: ref<inkAnimProxy>) -> Bool {
    let data: ENeutralizeType = IntEnum(0l);
    this.m_blackboard.SetVariant(GetAllBlackboardDefs().UI_Crosshair.EnemyNeutralized, ToVariant(data));
  }
}

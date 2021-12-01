
public class ReserveWorkSpotTask extends WorkSpotTask {

  public let workspotRef: NodeRef;

  public let workspotObject: wref<GameObject>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reserveWorkspotEvent: ref<OnReserveWorkspotEvent> = new OnReserveWorkspotEvent();
    this.workspotRef = ScriptExecutionContext.GetArgumentNodeRef(context, n"WorkspotNode");
    reserveWorkspotEvent.workspotRef = this.workspotRef;
    this.workspotObject = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    this.workspotObject.QueueEvent(reserveWorkspotEvent);
  }
}

public class ReleaseWorkSpotTask extends WorkSpotTask {

  public let workspotRef: NodeRef;

  public let workspotObject: wref<GameObject>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reserveWorkspotEvent: ref<OnReleaseWorkspotEvent> = new OnReleaseWorkspotEvent();
    this.workspotRef = ScriptExecutionContext.GetArgumentNodeRef(context, n"WorkspotNode");
    reserveWorkspotEvent.workspotRef = this.workspotRef;
    this.workspotObject = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    this.workspotObject.QueueEvent(reserveWorkspotEvent);
  }
}

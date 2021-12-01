
public native class IKTargetRemoveEvent extends Event {

  private native let ikTargetRef: IKTargetRef;

  public final static func QueueRemoveIkTargetRemoveEvent(owner: ref<GameObject>, ikEvent: ref<IKTargetAddEvent>) -> Void {
    let removeLookatEvent: ref<IKTargetRemoveEvent> = new IKTargetRemoveEvent();
    removeLookatEvent.ikTargetRef = ikEvent.outIKTargetRef;
    owner.QueueEvent(removeLookatEvent);
  }
}

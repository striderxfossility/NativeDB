
public native class gameNavmeshDetector extends IPlacedComponent {

  protected final func OnNavmeshStateChanged(onNavmesh: Bool, navmeshDistance: Float, overlapGeometry: Bool) -> Void {
    Log("OnNavmeshStateChanged " + onNavmesh + navmeshDistance);
  }
}

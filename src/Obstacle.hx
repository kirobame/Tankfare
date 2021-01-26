using Extensions;

class Obstacle extends Observable
{
    var box : h3d.scene.Box;
    var graphs : h3d.scene.Object;

    public function new(graphs : h3d.scene.Object)
    {
        super();

        this.graphs = graphs;
        addChild(graphs);
        graphs.setPosition(0, 0, 0);
    }
    public function init()
    {
        ev.Courier.subscribeTo(ev.Courier.CallbackKind.OnTankTransformIntent, onPlayerMoveIntent);
        ev.Courier.subscribeTo(ev.Courier.CallbackKind.OnBulletTransformIntent, onBulletMoveIntent);
    }

    function onPlayerMoveIntent(args : ev.Courier.CallbackArgs)
    {
        switch(args)
        {
            case ev.Courier.CallbackArgs.ColliderArgs(collider):
                
                var bounds = getBounds(new h3d.col.Bounds());
                if (collider.overlaps(bounds)) return ev.Courier.ListenerOutput.Break;

            case _:
        }

        return ev.Courier.ListenerOutput.Empty;
    }
    function onBulletMoveIntent(args : ev.Courier.CallbackArgs)
    {
        switch(args)
        {
            case ev.Courier.CallbackArgs.RayArgs(ray, len):

                var bounds = getBounds(new h3d.col.Bounds());
                var dist = bounds.rayIntersection(ray, true);

                if (dist > 0 && dist < len)
                {
                    var dir = ray.getDir();
                    dir.normalize();

                    dir.x *= dist;
                    dir.y *= dist;

                    var point = new h3d.Vector(ray.px + dir.x, ray.py + dir.y, ray.pz);
                    
                    if (point.x > bounds.xMin && point.x < bounds.xMax)
                    {
                        if (point.y < bounds.yMin) return ev.Courier.ListenerOutput.Reflect(point, new h3d.Vector(0, -1));
                        else return ev.Courier.ListenerOutput.Reflect(point, new h3d.Vector(0, 1));
                    }
                    else if (point.x < bounds.xMin) return ev.Courier.ListenerOutput.Reflect(point, new h3d.Vector(-1, 0));
                    else return ev.Courier.ListenerOutput.Reflect(point, new h3d.Vector(1, 0));
                }

            case _:
        }

        return ev.Courier.ListenerOutput.Empty;
    }

    override function clone(?o:h3d.scene.Object):h3d.scene.Object 
    {
        if (o == null) o = new Obstacle(graphs.clone());
        o.name = "Obstacle";

        return o;
    }
}
using Extensions;

class Obstacle extends h3d.scene.Object
{
    var box : h3d.scene.Box;
    var graph : h3d.scene.Object;

    public function new(graph : h3d.scene.Object)
    {
        super();

        this.graph = graph;
        addChild(graph);
        graph.setPosition(0, 0, 0);

        ev.Courier.subscribeTo(ev.Courier.CallbackKind.OnTankTransformIntent, onPlayerMoveIntent);
    }

    function onPlayerMoveIntent(args : ev.Courier.CallbackArgs)
    {
        switch(args)
        {
            case ev.Courier.CallbackArgs.ColliderArgs(collider):
                
                if (ignoreCollide) return ev.Courier.ListenerOutput.Empty;
                var bounds = getBounds(new h3d.col.Bounds());

                if (collider.overlaps(bounds)) return ev.Courier.ListenerOutput.Break;

            case _:
        }

        return ev.Courier.ListenerOutput.Empty;
    }

    override function clone(?o:h3d.scene.Object):h3d.scene.Object 
    {
        if (o == null) o = new Obstacle(graph.clone());
        super.clone(o);

        return o;
    }
}
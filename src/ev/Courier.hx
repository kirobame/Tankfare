package ev;

class Courier
{
    static var callbacks : haxe.ds.Map<CallbackKind, haxe.ds.List<CallbackArgs -> ListenerOutput>>;

    static public function init()
    {
        callbacks = new haxe.ds.Map<CallbackKind, haxe.ds.List<CallbackArgs -> ListenerOutput>>();
    }

    static public function open(kind : CallbackKind)
    {
        if (callbacks.exists(kind)) return;
        callbacks.set(kind, new haxe.ds.List<CallbackArgs -> ListenerOutput>());
    }

    static public function subscribeTo(kind : CallbackKind, listener : CallbackArgs -> ListenerOutput)
    {
        if (!callbacks.exists(kind))
        {
            var list = new haxe.ds.List<CallbackArgs -> ListenerOutput>();
            list.add(listener);

            callbacks.set(kind, list);
            return;
        }

        callbacks.get(kind).add(listener);
    }
    static public function unsubscribeFrom(kind : CallbackKind, listener : CallbackArgs -> ListenerOutput)
    {
        if (!callbacks.exists(kind)) return;
        callbacks.get(kind).remove(listener);
    }

    static public function call(kind : CallbackKind, args : CallbackArgs)
    {
        for (delegate in callbacks.get(kind)) delegate(args);
    }

    static public function ping(kind : CallbackKind, args : CallbackArgs)
    {
        for (delegate in callbacks.get(kind))
        {
            var output = delegate(args);
            if (output != Empty) return output;
        }

        return ListenerOutput.Empty;
    }
    static public function check(kind : CallbackKind, args : CallbackArgs, predicate : ListenerOutput -> Bool)
    {
        for (delegate in callbacks.get(kind))
        {
            var output = delegate(args);
            if (predicate(output)) return output;
        }
    
        return ListenerOutput.Empty;
    }
}

enum CallbackKind
{
    OnUpdate;
    OnTankTransformIntent;
}
enum CallbackArgs
{
    FloatArgs(val : Float);
    BoundArgs(bounds : h3d.col.Bounds);
    ColliderArgs(collider : h3d.col.Collider);
}
enum ListenerOutput
{
    Empty;
    Break;
}
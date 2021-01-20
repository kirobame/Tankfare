class Extensions 
{
    static public function toObj(model : hxd.res.Model, color : Int)
    {
        var cache = new h3d.prim.ModelCache();
        var obj = cache.loadModel(model);

        for (mesh in obj.getMeshes()) mesh.material.color.setColor(color);

        return obj;
    }
}
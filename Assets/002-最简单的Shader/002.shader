Shader "Unlit/002"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            fixed4 _Color;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                fixed3 color: COLOR0;
            };
			
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                o.color = _Color.rgb;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(i.color, 1);
            }
			ENDCG
		}
	}
}

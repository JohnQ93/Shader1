Shader "Unlit/005"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("DiffuseColor", Color) = (1,1,1,1)
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
			
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;

			struct v2f
			{
				float4 vertex: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldLight, i.worldNormal) * 0.5 + 0.5);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				return fixed4(diffuse + ambient, 1);
			}
			ENDCG
		}
	}
}

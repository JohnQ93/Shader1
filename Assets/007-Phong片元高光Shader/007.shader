Shader "Unlit/007"
{
    Properties
	{
        _Diffuse ("DiffuseColor", Color) = (1,1,1,1)
		_Specular ("SpecularColor", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(1,255)) = 5
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
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0;
				fixed3 worldPos: TEXCOORD1;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, i.worldNormal));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 reflectDir = 2 * dot(i.worldNormal, worldLight) * i.worldNormal - worldLight;
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir,reflectDir)),_Gloss);
				fixed3 color = diffuse + ambient + specular;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}

Shader "Unlit/006"
{
    Properties
	{
        _Diffuse ("DiffuseColor", Color) = (1,1,1,1)
		_Specular ("SpecularColor", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(1,100)) = 5
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
				fixed3 color: COLOR0;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 reflectDir = 2 * dot(worldNormal, worldLight) * worldNormal - worldLight;
				//fixed3 reflectDir = reflect(-worldLight, worldNormal);
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - UnityObjectToWorldDir(v.vertex));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(viewDir,reflectDir)),_Gloss);
				o.color = diffuse + specular + ambient;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color, 1);
			}
			ENDCG
		}
	}
}

﻿Shader "Unlit/012"
{
    Properties
	{
		_RampTex("RampTexture", 2D) = "white" {}
        _Diffuse ("DiffuseColor", Color) = (1,1,1,1)
		_Specular ("SpecularColor", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(1,255)) = 10
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

			sampler2D _RampTex;
			float4 _RampTex_ST;
            fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0;
				fixed3 worldPos: TEXCOORD1;
				float2 uv: TEXCOORD2;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex); //v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//漫反射
				fixed halfLambert = saturate(dot(worldLight, i.worldNormal)) * 0.5 + 0.5;
				fixed3 albedo = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;   //渐变纹理
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//高光反射
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);
				fixed3 color = diffuse + ambient + specular;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}

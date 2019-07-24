Shader "Unlit/013"
{
    Properties
	{
		_MainTexture("MainTexture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", float) = 1
		_SpecularMask("Specular Mask", 2D) = "white" {}
		_SpecularScale("Specular Scale", Range(0, 1)) = 1
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

			sampler2D _MainTexture;
			float4 _MainTexture_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			sampler2D _SpecularMask;
			float4 _SpecularMask_ST;
			float _SpecularScale;
			float _BumpScale;
            fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex: SV_POSITION;
				fixed3 tangentView: TEXCOORD0;
				fixed3 tangentLight: TEXCOORD1;
				float4 uv: TEXCOORD2;
				float2 maskUv: TEXCOORD3;
			};

			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTexture); //v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.maskUv = TRANSFORM_TEX(v.texcoord, _SpecularMask);

				//求副切线向量  TANGENT_SPACE_ROTATION
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				o.tangentView = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
				o.tangentLight = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//漫反射
				fixed3 albedo = tex2D(_MainTexture, i.uv.xy).rgb;
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				//贴图没有设置成normal map
				//fixed3 tangentNormal;
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				//贴图设置成normal map
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;

				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (saturate(dot(i.tangentLight, tangentNormal)));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//高光遮罩
				float specularMask = tex2D(_SpecularMask, i.maskUv).b * _SpecularScale;

				//高光反射
				fixed3 halfDir = normalize(i.tangentView + i.tangentLight);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;
				fixed3 color = diffuse + ambient + specular;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}

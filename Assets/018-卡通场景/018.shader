Shader "Unlit/018"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_BumpMap ("Bump Tex", 2D) = "white" {}
		_BumpScale ("Bump Scale", float) = 1
		_Outline ("Outline", Range(0, 0.3)) = 0.01
		_OutlineColor ("OutlineColor", Color) = (0, 0, 0, 0)
		_Steps ("Steps", Range(1, 30)) = 1
		_ToonEffect ("ToonEffect", Range(0, 1)) = 0.5
		//_Snow ("Snow", Range(0, 1)) = 0.5
		_SnowDir ("SnowDir", Vector) = (0, 1, 0, 1)
		_SnowColor ("SnowColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

		UsePass "Unlit/017/Outline"

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile __ SNOW_ON

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Diffuse;
			float _Steps;
			float _ToonEffect;
			float _Snow;
			float4 _SnowDir;
			fixed4 _SnowColor;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				//切线空间转换到世界空间的矩阵
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));

                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv.xy);

				// sample the bump texture
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				float3 worldNormal = normalize(float3(dot(i.TtoW0.xyz, tangentNormal), dot(i.TtoW1.xyz, tangentNormal), dot(i.TtoW2, tangentNormal)));

				float difLight = dot(worldNormal, worldLight) * 0.5 + 0.5;
				difLight = smoothstep(0, 1, difLight);
				float toon = floor(difLight * _Steps) / _Steps;
				difLight = lerp(difLight, toon, _ToonEffect);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * difLight;

				#if SNOW_ON
				if (dot(worldNormal, _SnowDir.xyz) > lerp(1, -1, _Snow))
				{
					diffuse = _SnowColor;
				}
				#endif

                return fixed4(diffuse + ambient, 1);
            }
            ENDCG
        }
    }
}

Shader "Unlit/017"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse ("Color", Color) = (1, 1, 1, 1)
		//轮廓描边
		_Outline ("Outline", Range(0, 0.1)) = 0.01
		_OutlineColor ("OutlineColor", Color) = (0, 0, 0, 0)
		//渐变色
		_Steps ("Steps", Range(1, 30)) = 1
		_ToonEffect ("ToonEffect", Range(0, 1)) = 0.5
		//边缘光
		_RimColor ("RimColor", Color) = (1, 1, 1, 1)
		_RimPower("RimPower", Range(0.001, 3)) = 1
		//Xray
		_XrayColor ("XrayColor", Color) = (1, 1, 1, 1)
		_XrayPower("XrayPower", Range(0.001, 3)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Geometry+100" "RenderType"="Opaque" }
        LOD 100

		Pass
		{
			Tags { "ForceNoShadowCasting"="true" }
			Name "Xray"
			Blend SrcAlpha One
			ZWrite Off
			ZTest Greater

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _XrayColor;
			float _XrayPower;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal: TEXCOORD0;
				float3 viewDir: TEXCOORD1;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				float xray = 1 - dot(viewDir, normal);
				return _XrayColor * pow(xray, 1/_XrayPower);
			}

			ENDCG
		}

		Pass
		{
			Name "Outline"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float _Outline;
			fixed4 _OutlineColor;

			v2f vert(appdata_base v)
			{
				v2f o;
				//物体空间法线外拓
				v.vertex.xyz += v.normal * _Outline;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//视角空间法线外拓
				//float3 viewPos = UnityObjectToViewPos(v.vertex.xyz); //mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld, v.vertex));
				//float3 viewN = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				//viewPos += viewN * _Outline;
				//o.vertex = mul(UNITY_MATRIX_P, viewPos);

				//裁剪空间法线外拓
				//o.vertex = UnityObjectToClipPos(v.vertex);
				//float3 viewN = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				//float2 viewNormal = TransformViewToProjection(viewN.xy);
				//o.vertex.xy += viewNormal * _Outline;

				return o;
			}

			float4 frag(v2f i):SV_Target
			{
				return _OutlineColor;
			}

			ENDCG
		}
		
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			float _Steps;
			float _ToonEffect;
			fixed4 _RimColor;
			float _RimPower;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//贴图采样
                fixed4 albedo = tex2D(_MainTex, i.uv);

                //漫反射
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float difLight = dot(worldLight, i.worldNormal) * 0.5 + 0.5;

				//颜色在[0,1]之间
				difLight = smoothstep(0, 1, difLight);
				//颜色离散化
				float toon = floor(difLight * _Steps) / _Steps;
				difLight = lerp(difLight, toon, _ToonEffect);

				//RimColor
				float rim = 1 - dot(i.worldNormal, viewDir);       //点积越接近1越在中央，越接近0越靠边缘。(用1-rim，更适合做次方)
				fixed4 rimColor = _RimColor * pow(rim, 1/_RimPower);

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * difLight;

                return fixed4(diffuse+ambient+rimColor, 1);
            }
            ENDCG
        }
		
    }
}

Shader "Unlit/011"
{
    Properties
	{
		_MainTexture("MainTexture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", float) = 1
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
			sampler2D _BumpMap;
			float4 _MainTexture_ST;
			float4 _BumpMap_ST;
			float _BumpScale;
            fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex: SV_POSITION;
				float4 uv: TEXCOORD0;
				float4 TtiW0: TEXCOORD1;
				float4 TtiW1: TEXCOORD2;
				float4 TtiW2: TEXCOORD3;
			};

			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//节省寄存器，将两个uv合并储存
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTexture); //v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				//切线空间转世界空间矩阵，按列摆放
				o.TtiW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtiW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtiW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//顶点世界坐标
				float3 worldPos = float3(i.TtiW0.w, i.TtiW1.w, i.TtiW2.w);

				//光源方向和视角方向
				float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				//法线纹理采样，得到切线空间下法线方向
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;

				//切线空间下法线转换到世界空间
				fixed3 worldNormal = fixed3(dot(i.TtiW0.xyz, tangentNormal), dot(i.TtiW1.xyz, tangentNormal), dot(i.TtiW2.xyz, tangentNormal));

				//漫反射
				fixed3 albedo = tex2D(_MainTexture, i.uv.xy).rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (saturate(dot(lightDir, worldNormal)));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//高光反射
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				fixed3 color = diffuse + ambient + specular;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}

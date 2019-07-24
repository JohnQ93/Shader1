Shader "Unlit/016"
{
    Properties
	{
		_MainTexture("MainTexture", 2D) = "white" {}
        _Diffuse ("DiffuseColor", Color) = (1,1,1,1)
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100

		Pass
		{
			ZWrite On
			ColorMask 0
		}

		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

			sampler2D _MainTexture;
			float4 _MainTexture_ST;
            fixed4 _Diffuse;
			fixed _AlphaScale;

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
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTexture); //v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//漫反射
				fixed4 mainColor = tex2D(_MainTexture, i.uv);

				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * mainColor.rgb * _Diffuse.rgb * ((dot(worldLight, i.worldNormal)) * 0.5 + 0.5);

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 color = diffuse + ambient;
				return fixed4(color, mainColor.a * _AlphaScale);
			}
			ENDCG
		}
	}
	//FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}

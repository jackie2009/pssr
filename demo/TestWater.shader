Shader "Unlit/TestWater"
{
	Properties
	{
		_Color ("color", Color) = (1,1,1,1)
		_ReflectionColor ("_ReflectionColor", Color) = (0.5,0.5,0.5,1)
		_ReflectionIntensity("ReflectionIntensity", Range(0,1)) = 0.8
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		blend srcAlpha oneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		 
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
			 
				float4 vertex : SV_POSITION;
			};

			 
			fixed4 _Color;
			fixed4 _ReflectionColor;
			fixed _ReflectionIntensity;
			uniform sampler2D WaterPssrTex;
			uniform int WaterPssrTexSize;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =   ComputeScreenPos(o.vertex);
			 
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = _Color;
			float2 screenPos = i.uv.xy / i.uv.w;
		
				
				 
			//根据自己需求 如果要更好性能 可以用 相邻4对角 代替12 泊松分布
	 float2 poisson[12] = { float2(-0.326212f, -0.40581f),
	  float2(-0.840144f, -0.07358f),
	  float2(-0.695914f, 0.457137f),
	  float2(-0.203345f, 0.620716f),
	  float2(0.96234f, -0.194983f),
	  float2(0.473434f, -0.480026f),
	  float2(0.519456f, 0.767022f),
	  float2(0.185461f, -0.893124f),
	  float2(0.507431f, 0.064425f),
	  float2(0.89642f, 0.412458f),
	  float2(-0.32194f, -0.932615f),
	  float2(-0.791559f, -0.59771f) };
     half ref =0;
	 float offsetScale = 8;
				for (int i = 0; i < 12;i++) {
					ref += tex2D(WaterPssrTex, screenPos.xy + poisson[i]* offsetScale / WaterPssrTexSize ).r;
				}
	         ref /= 12;
			  col.rgb = lerp(_Color.rgb,  _ReflectionColor.rgb, _ReflectionIntensity*ref);
				return col;
			}
			ENDCG
		}
	}
}

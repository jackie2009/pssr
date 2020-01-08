// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'

// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'

// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SSToWorldPos"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
			 
				 
				float4 vertex : SV_POSITION;
			 float3 ray : TEXCOORD1;
			};

			uniform float4x4	frustumCorners;
			uniform sampler2D _CameraDepthTexture;
			v2f vert (appdata v)
			{
				v2f o;


			 o.vertex = UnityObjectToClipPos(v.vertex);
			 
			 o.uv = v.uv;
			
			 uint x = (uint)(o.uv.x * 1.5);
			 uint y = (uint)(o.uv.y * 1.5);
			 half index = y * 2 + x;//取得索引
			 o.ray = frustumCorners[index].xyz;//根据在程序中计算好的顶点z值作为索引
			 
			 
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

		 
	 float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
			depth = Linear01Depth(depth);
			 
		  fixed4 worldPos = fixed4(depth*i.ray, 1);

			worldPos.xyz += _WorldSpaceCameraPos;
			if (depth > 0.9) return 0;
 
return worldPos;
/*
				// float  ray = mul(UNITY_MATRIX_MV, v.vertex).xyz * float3(-1, -1, 1);
				 float  ray = mul(UNITY_MATRIX_MV, v.vertex).xyz * float3(-1, -1, 1);
				 ray = ray * (_ProjectionParams.z / ray.z);
			//screen position of UV / depth
	 

			float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
			depth = Linear01Depth(depth);

			float4 viewPos = float4(ray * depth, 1);
			float3 worldPos = mul(_CameraToWorld, viewPos).xyz;
				// sample the texture
			fixed4 col = 1;
				col.rgb= worldPos;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
				*/
			}
			ENDCG
		}
	}
}

Shader "USB/USB_SDF_plane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}        
        _Edge ("Edge", Range(-0.5, 0.5)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
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
                float3 hitPos : TEXCOORD2;  
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Edge;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hitPos = v.vertex; 
                return o;
            }

            #define MAX_MARCHING_STEPS 50
            #define MAX_DISTANCE 10.0
            #define SURFACE_DISTANCE 0.001

            float planeSDF(float3 ray_position)
            {     
                float plane = ray_position.y - _Edge;
                return plane;
            }

            float sphereCasting(float3 ray_origin, float3 ray_direction)
            {     
                float distance_origin = 0;
                for(int i = 0; i < MAX_MARCHING_STEPS; i++)
                {
                    // ray_position se refiere a cada punto de encuentro en la marcha
                    float3 ray_position = ray_origin + ray_direction * distance_origin;
                    float distance_scene = planeSDF(ray_position);
                    distance_origin += distance_scene;

                    if(distance_scene < SURFACE_DISTANCE || distance_origin > MAX_DISTANCE) 
                        break;
                }

                return distance_origin;
            }

            float3 normals(float3 p) // point e.xyy = float3 (1e-2, 0, 0);
            {     
                /*           
                float3 n = planeSDF(p) - float3(
                    planeSDF(p - float3(0.01, 0, 0)), 
                    planeSDF(p - float3(0, 0.01, 0)), 
                    planeSDF(p - float3(0, 0, 0.01)));
                */

                float e = 0.01;
                float3 n = float3(
                    planeSDF(float3(p.x + e, p.y, p.z)) - planeSDF(float3(p.x - e, p.y, p.z)),
                    planeSDF(float3(p.x, p.y + e, p.z)) - planeSDF(float3(p.x, p.y - e, p.z)),
                    planeSDF(float3(p.x, p.y, p.z + e)) - planeSDF(float3(p.x, p.y, p.z - e))
                );

                return normalize(mul(unity_ObjectToWorld, n));
            }

            fixed4 frag (v2f i, bool face : SV_isFrontFace) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 ray_direction = normalize(i.hitPos - ray_origin); 

                float t = sphereCasting(ray_origin, ray_direction);
                float3 p = ray_origin + ray_direction * t;    

                if(i.hitPos.y > _Edge) discard;
                    
                return face ? col : float4(p, 1);
            }
            ENDCG
        }
    }
}

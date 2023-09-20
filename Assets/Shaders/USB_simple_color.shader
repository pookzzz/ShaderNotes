Shader "USB/USB_simple_color"
{
    Properties
    {
        [Header(Specular Properties)]
        _Specularity("Specularity", Range(0.01, 1)) = 0.08
        [PowerSlider(3.0)] _Brightness("Brightness", Range(0.01, 1.)) = 0.08
        _SpecularColor("Color", Color) = (1, 1, 1,1)

        [Space(20)]
        [Header(Texture Properties)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Space(20)]
        [Header(Other Properties)]
        // [Toggle] _Enable ("Turn On", FLoat) = 0
        [KeywordEnum(Off, Red, Blue)] _Options ("Options?", Float) = 0
        [Enum(Off, 0, Front, 1, Back, 2)]_Face ("Culling", Float) = 0
        [IntRange] _Samples("Samples", Range(0, 255))=100
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull[_Face]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            // #pragma shader_feature _ENABLE_ON
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Brightness;
            int _Samples;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);

                // #if _ENABLE_ON
                //     return col;
                // #else
                //     return col * _Color;
                // #endif

                #if _OPTIONS_OFF
                    return col;
                #elif _OPTIONS_BLUE
                    return col * float4(0.0, 0.0, 1.0, 1.0);
                #elif _OPTIONS_RED
                    return col * float4(1.0, 0.0, 0.0, 1.0);
                #endif
                    
            }

            ENDCG
        }
    }
}

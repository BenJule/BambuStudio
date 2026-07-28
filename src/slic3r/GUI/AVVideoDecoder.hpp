#ifndef AVVIDEODECODER_HPP
#define AVVIDEODECODER_HPP

#include "Printer/BambuTunnel.h"

#ifndef BAMBUSTUDIO_NO_AVVIDEODECODER
extern "C" {
    #include <libavcodec/avcodec.h>
    #include <libswscale/swscale.h>
}
#endif // BAMBUSTUDIO_NO_AVVIDEODECODER
#include <vector>
#include <wx/bitmap.h>
#include <wx/gdicmn.h>
#include <wx/image.h>

class wxBitmap;

class AVVideoDecoder
{
public:
    AVVideoDecoder();

    ~AVVideoDecoder();

public:
    int  open(Bambu_StreamInfo const &info);

    int  reopen(Bambu_StreamInfo const &info);

    int  decode(Bambu_Sample const &sample);

    int  flush();

    void close();

    bool got_frame() const { return got_frame_; }

    bool toWxImage(wxImage &image, wxSize const &size);

    bool toWxBitmap(wxBitmap &bitmap, wxSize const & size);

private:
#ifndef BAMBUSTUDIO_NO_AVVIDEODECODER
    AVCodecContext *codec_ctx_ = nullptr;
    AVFrame *       frame_     = nullptr;
    SwsContext *    sws_ctx_   = nullptr;
#endif // BAMBUSTUDIO_NO_AVVIDEODECODER
    bool got_frame_ = false;
    int width_ { 0 }; // scale result width
    std::vector<uint8_t> bits_;
};

#endif // AVVIDEODECODER_HPP

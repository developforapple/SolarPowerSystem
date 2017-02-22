// getAllImg   getShareContent(contentLength)
function getShareContent(contentLength) {
    var d = document.getElementsByTagName("p"),
    a = "";
peng: for (var h = 0; h < d.length; h++) {
    var o = d[h],
    k = o.childNodes,
    f = true;
chuan: for (var g = 0; g < k.length; g++) {
    var n = k[g],
				l = n.nodeType;
    if (l !== 3) {
        f = false
    } else {
        f = true;
        break chuan
    }
}
    if (f) {
        var c = "";
        try {
            c = o.innerText.trim()
        } catch (m) {}
        if (c.length < 1) {
            continue
        }
        a = c.substring(0, contentLength);
        break peng
    }
}
    return a
}

function getAllImg() {
    var imgs = document.getElementsByTagName("img");
    var arr = new Array();
    
    for (var i=0;i<imgs.length;i++){
        var img = imgs[i];
        var src = img.getAttribute("src");
        if (src.indexOf(".gif") < 0 &&
            src.indexOf(".GIF") < 0 &&
            img.naturalWidth >= 50 &&
            img.naturalHeight >= 50){
            arr.push(src);
        }
    }
    var json = JSON.stringify(arr);
    return json;
}

document.onreadystatechange = function(e) {
    if (document.readyState == 'interactive') {
        var imgs = document.getElementsByTagName("img");
        for (var h = 0; h < imgs.length; h++) {
            imgs[h].onclick = function() {
                
                var left = this.offsetLeft;
                var top = this.offsetTop;
                var width = this.width;
                var height = this.height;
                var src = this.getAttribute("src");
                
                if (src.length > 1 &&
                    src.indexOf(".gif") < 0 &&
                    src.indexOf(".GIF") < 0 &&
                    width >= 50 &&
                    height >= 50) {
                    var dict = {"x":left,"y":top,"w":width,"h":height,"src":src};
                    window.webkit.messageHandlers.getImgSrc.postMessage(dict);
                }
            }
        }
    }
};

function YGShareContent(){
    var json;
    if (typeof shareData == 'undefined' || shareData == 'undefined'){
        var title,desc,imgUrl,link;
        
        if(typeof msg_title != 'undefined' && msg_title.length != 0){
            title = msg_title;
        }else{
            title = document.title;
        }
        
        if(typeof msg_desc != 'undefined' && msg_desc.length != 0){
            desc = msg_desc;
        }else{
            desc = getShareContent(80);
        }
        
        if(typeof msg_cdn_url != 'undefined' && msg_cdn_url.length != 0){
            imgUrl = msg_cdn_url;
        }else{
            imgUrl = document.images[0].src;
        }
        
        if(typeof msg_link != 'undefined' && msg_link.length != 0){
            link = msg_link;
        }else{
            link = document.URL;
        }
        
        var data = {
        title:	title,
        desc:	desc,
        link:	link,
        imgUrl:	imgUrl,
        type:	'link',
        dataUrl:'',
        success:'',
        cancel:	''
        }
        json = JSON.stringify(data);
    }else{
        json = JSON.stringify(shareData);
    }
    return json;
}

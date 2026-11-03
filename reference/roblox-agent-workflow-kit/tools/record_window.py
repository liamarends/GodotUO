"""Windows window-only silent recording; requires FFmpeg + ffprobe on PATH."""
import argparse, json, os, pathlib, shutil, subprocess

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--title', required=True)
    p.add_argument('--seconds', type=int, default=30)
    p.add_argument('--run', type=pathlib.Path, required=True)
    a = p.parse_args()
    if os.name != 'nt': p.error('This gdigrab helper needs Windows; use a validated OBS backend elsewhere')
    if not 1 <= a.seconds <= 3600: p.error('seconds must be 1..3600')
    if not a.run.is_dir(): p.error('Create an evidence run first')
    for executable in ('ffmpeg','ffprobe'):
        if not shutil.which(executable): p.error(executable+' missing; install FFmpeg and add its bin folder to PATH')
    for folder in ('clips','stills','logs','data'): (a.run/folder).mkdir(exist_ok=True)
    video = a.run/'clips/window.mp4'
    still = a.run/'stills/first-frame.png'
    if video.exists() or still.exists(): p.error('Capture already exists; use a new run')
    if shutil.disk_usage(a.run).free < 1024**3: p.error('Less than 1 GiB free; free space before recording')
    cmd = ['ffmpeg','-nostdin','-n','-f','gdigrab','-framerate','30','-i','title='+a.title,
           '-t',str(a.seconds),'-an','-vf','pad=ceil(iw/2)*2:ceil(ih/2)*2',
           '-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(video)]
    try:
        with (a.run/'logs/capture.log').open('w', encoding='utf-8') as log:
            subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=a.seconds+30)
        probe = subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries',
            'stream=codec_name,width,height:format=duration','-of','json',str(video)],
            capture_output=True, text=True, check=True, timeout=15)
        data = json.loads(probe.stdout)
        if not data.get('streams') or float(data.get('format',{}).get('duration',0)) <= 0:
            raise ValueError('Missing video stream or duration')
        (a.run/'data/capture.json').write_text(json.dumps(data, indent=2), encoding='utf-8')
        subprocess.run(['ffmpeg','-nostdin','-n','-v','error','-i',str(video),'-frames:v','1',str(still)], check=True, timeout=30)
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        print('CAPTURE FAILED:', error)
        return 1
    print('Captured:', video, '\nInspect the clip and still before claiming visual success.')
    return 0
if __name__ == '__main__': raise SystemExit(main())

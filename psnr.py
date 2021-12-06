import cv2
import matplotlib.pyplot as plt

folder_name = 'scrambled_I_120'

orig_path = './' + folder_name + '/raw.avi'
bad_path = './' + folder_name + '/dec_cmp.avi'
good_path = './' + folder_name + '/cmp.mp4'

if __name__ == '__main__':
    print(folder_name)
    orig_cap = cv2.VideoCapture(orig_path)
    bad_cap = cv2.VideoCapture(bad_path)
    good_cap = cv2.VideoCapture(good_path)

    bad_result = []
    good_result = []

    while True:
        orig_ret, orig_frame = orig_cap.read()
        bad_ret, bad_frame = bad_cap.read()
        good_ret, good_frame = good_cap.read()

        if orig_ret and bad_ret and good_ret:
            bad_result.append(cv2.PSNR(orig_frame, bad_frame))
            good_result.append(cv2.PSNR(orig_frame, good_frame))
        else:
            break

    plt.figure(figsize=(9.0, 9.0))
    plt.title(folder_name.replace('_', ' '))
    plt.plot(bad_result, label='encrypted')
    plt.plot(good_result, label='normal')
    plt.legend()
    plt.show()


